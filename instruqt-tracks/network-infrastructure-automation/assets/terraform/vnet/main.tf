# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=3.72.0"
  features {}
}

resource "random_string" "participant" {
  length   = 4
  special  = false
  upper    = false
  numeric  = false
}

resource "azurerm_resource_group" "instruqt" {
  name     = "instruqt-nia-${random_string.participant.result}"
  location = "East US"
}

module "shared-svcs-network" {
  source              = "Azure/network/azurerm"
  version             = "3.5.0"
  vnet_name           = "shared-svcs-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  subnet_names        = ["Bastion", "Vault", "Consul"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

module "app-network" {
  source              = "Azure/network/azurerm"
  version             = "3.5.0"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "app-vnet"
  address_space       = "10.3.0.0/16"
  subnet_prefixes     = ["10.3.1.0/24","10.3.2.0/24","10.3.3.0/24","10.3.4.0/24"]
  subnet_names        = ["MGMT","INTERNET","DMZ","APP"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "bastion" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = module.shared-svcs-network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "bastion-vm"
  location              = azurerm_resource_group.instruqt.location
  resource_group_name   = azurerm_resource_group.instruqt.name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "bastion-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "bastion"
  admin_username = "azure-user"
  
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure-user"
    public_key = var.ssh_public_key
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

resource "azurerm_network_security_group" "bastion" {
  name                = "bastion-nsg"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  # Allow SSH traffic in from Internet to public subnet.
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
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_virtual_network_peering" "shared-app" {
  name                      = "SharedToapp"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "shared-svcs-vnet"
  remote_virtual_network_id = module.app-network.vnet_id
}

resource "azurerm_virtual_network_peering" "app-shared" {
  name                      = "appToShared"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "app-vnet"
  remote_virtual_network_id = module.shared-svcs-network.vnet_id
}
