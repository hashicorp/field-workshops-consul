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

resource "azurerm_public_ip" "vault" {
  name                = "vault-ip"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vault" {
  name                = "vault-nic"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[1]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "vault" {
  name                = "vault-lb"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "configuration"
    public_ip_address_id = azurerm_public_ip.vault.id
  }
}

resource "azurerm_lb_backend_address_pool" "vault" {
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id     = azurerm_lb.vault.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "vault" {
  network_interface_id    = azurerm_network_interface.vault.id
  ip_configuration_name   = "configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vault.id
}

resource "azurerm_lb_probe" "vault" {
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id     = azurerm_lb.vault.id
  name                = "vault-http"
  port                = 8200
}

resource "azurerm_lb_rule" "vault" {
  resource_group_name            = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id                = azurerm_lb.vault.id
  name                           = "vault"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8200
  frontend_ip_configuration_name = "configuration"
  probe_id                       = azurerm_lb_probe.vault.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.vault.id
}

resource "azurerm_linux_virtual_machine" "vault" {
  # IMPORTANT: IL-843 the Terraform resource name and the Azure
  # VM name must match for our track setup script to clean up
  # when Azure fails to make a VM
  name                  = "vault"
  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.vault.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }
  
  os_disk {
    # IMPORTANT: IL-843 the os disk name must be
    # "<tf resource name>-disk" for our Azure cleanup script to
    # work
    name              = "vault-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  computer_name  = "vault"
  admin_username = "azure-uzer"
  custom_data    = file("${path.module}/scripts/vault.sh")

  disable_password_authentication = true

  admin_ssh_key {
    username = "azure-user"
    key_data = var.ssh_public_key
  }

  tags = {
    environment = "staging"
  }

  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_network_security_group" "vault" {
  name                = "vault-nsg"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  security_rule {
    name                       = "allow-ssh-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-vault-http-all"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "vault" {
  network_interface_id      = azurerm_network_interface.vault.id
  network_security_group_id = azurerm_network_security_group.vault.id
}
