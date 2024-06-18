# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "azurerm_image" "ubuntu" {
  name_regex          = "hashistack-*"
  resource_group_name = "packer"
}

resource "azurerm_public_ip" "tgw" {
  name                = "consul-tgw-ip"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "consul-tgw" {
  name                = "consul-tgw-nic"
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  ip_configuration {
    name                          = "config"
    subnet_id                     = data.terraform_remote_state.infra.outputs.azure_shared_svcs_public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tgw.id
  }

  tags = {
    Name = "consul"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}

data "template_file" "azure-tgw-init" {
  template = file("${path.module}/scripts/azure_tgw.sh")
  vars = {
    env             = data.terraform_remote_state.infra.outputs.env
    ca_cert         = "test"
    subscription_id = data.azurerm_subscription.primary.subscription_id
  }
}

resource "azurerm_virtual_machine" "consul-tgw" {
  name                  = "consul-tgw-vm"
  location              = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name   = data.terraform_remote_state.infra.outputs.azure_rg_name
  network_interface_ids = [azurerm_network_interface.consul-tgw.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type         = "UserAssigned"
    identity_ids = [data.terraform_remote_state.iam.outputs.azure_consul_user_assigned_identity_id]
  }

  storage_image_reference {
    id = data.azurerm_image.ubuntu.id
  }
  storage_os_disk {
    name              = "consul-tgw-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "consul-tgw"
    admin_username = "ubuntu"
    custom_data    = data.template_file.azure-tgw-init.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    Name = "consul-tgw"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}
