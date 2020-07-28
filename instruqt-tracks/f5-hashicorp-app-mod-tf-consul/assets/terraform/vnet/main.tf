provider "azurerm" {
  version = "=2.13.0"
  features {}
}

resource "random_string" "participant" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "azurerm_resource_group" "instruqt" {
  name     = "instruqt-f5-tf-consul-azure-${random_string.participant.result}"
  location = "East US"
}

module "shared-svcs-network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "shared-svcs-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24", "10.2.1.0/24"]
  subnet_names        = ["Bastion", "Vault"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

module "legacy-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "legacy-vnet"
  address_space       = "10.3.0.0/16"
  subnet_prefixes     = ["10.3.0.0/24"]
  subnet_names        = ["VM"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

module "aks-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "aks-vnet"
  address_space       = "10.4.0.0/16"
  subnet_prefixes     = ["10.4.0.0/24"]
  subnet_names        = ["kube"]

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

resource "azurerm_virtual_machine" "bastion" {
  name                  = "bastion-vm"
  location              = azurerm_resource_group.instruqt.location
  resource_group_name   = azurerm_resource_group.instruqt.name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "bastion-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "bastion"
    admin_username = "azure-user"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    environment = "staging"
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

resource "azurerm_virtual_network_peering" "shared-legacy" {
  name                      = "SharedToLegacy"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "shared-svcs-vnet"
  remote_virtual_network_id = module.legacy-network.vnet_id
}

resource "azurerm_virtual_network_peering" "legacy-shared" {
  name                      = "LegacyToShared"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "legacy-vnet"
  remote_virtual_network_id = module.shared-svcs-network.vnet_id
}

resource "azurerm_virtual_network_peering" "shared-aks" {
  name                      = "SharedToAKS"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "shared-svcs-vnet"
  remote_virtual_network_id = module.aks-network.vnet_id
}

resource "azurerm_virtual_network_peering" "aks-shared" {
  name                      = "AKSToShared"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "aks-vnet"
  remote_virtual_network_id = module.shared-svcs-network.vnet_id
}

resource "azurerm_virtual_network_peering" "aks-legacy" {
  name                      = "AksToLegacy"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "aks-vnet"
  remote_virtual_network_id = module.legacy-network.vnet_id
}

resource "azurerm_virtual_network_peering" "legacy-aks" {
  name                      = "LegacyToAKS"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "legacy-vnet"
  remote_virtual_network_id = module.aks-network.vnet_id
}
