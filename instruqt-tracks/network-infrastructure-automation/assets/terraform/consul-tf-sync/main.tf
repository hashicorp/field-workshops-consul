# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=3.72.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

# Create network interface
resource "azurerm_network_interface" "cts-nic" {
    name                      = "ctsNIC"
    location                  = "eastus"
    resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name

    ip_configuration {
        name                          = "ctsNicConfiguration"
        subnet_id                     = data.terraform_remote_state.vnet.outputs.mgmt_subnet
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "Instruqt"
    }
  
  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_linux_virtual_machine" "consul-terraform-sync" {
  name = "consul-terraform-sync"

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.cts-nic.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "ctsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name        = "consul-terraform-sync"
  admin_username       = "azure-user"
  custom_data          = base64encode(templatefile("./scripts/consul-tf-sync.sh", { vault_token = var.vault_token, vault_addr = var.vault_addr, consul_server_ip = var.consul_server_ip, bigip_mgmt_addr = var.bigip_mgmt_addr, bigip_admin_user = var.bigip_admin_user, panos_mgmt_addr = var.panos_mgmt_addr, panos_username = var.panos_username }))

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure-user"
    public_key = var.ssh_public_key
  }

  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }

}

resource "azurerm_network_interface_security_group_association" "cts" {
  network_interface_id      = azurerm_network_interface.cts-nic.id
  network_security_group_id = azurerm_network_security_group.cts-sg.id
}
