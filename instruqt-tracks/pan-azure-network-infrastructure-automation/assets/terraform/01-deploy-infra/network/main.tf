

module "secure-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group_name
  vnet_name           = "secure-network"
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.0.0/24", "10.1.1.0/24","10.1.2.0/24"]
  subnet_names        = ["Public", "Private", "Mgmt"]
  
  tags = {
    owner = var.owner
  }
}


module "shared-network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "shared-network"
  resource_group_name = var.resource_group_name
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  subnet_names        = ["Boundary", "Vault", "Consul"]

  tags = {
    owner = var.owner
  }
}


module "app-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group_name
  vnet_name           = "app-network"
  address_space       = "10.3.0.0/16"
  subnet_prefixes     = ["10.3.0.0/24","10.3.1.0/24", "10.3.2.0/24"]
  subnet_names        = ["WEB", "APP", "DB"]
  
  tags = {
    owner = var.owner
  }
}


# VNET Peering between shared and secure
resource "azurerm_virtual_network_peering" "sharedTOsecure" {
  name                      = "sharedTOsecure"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "shared-network"
  remote_virtual_network_id = module.secure-network.vnet_id
}

resource "azurerm_virtual_network_peering" "secureToshared" {
  name                      = "secureToshared"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "secure-network"
  remote_virtual_network_id = module.shared-network.vnet_id
}

# VNET Peering between secure and app vnet
resource "azurerm_virtual_network_peering" "secureTOapp" {
  name                      = "secureTOapp"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "secure-network"
  remote_virtual_network_id = module.app-network.vnet_id
}

resource "azurerm_virtual_network_peering" "appTOsecure" {
  name                      = "appTOsecure"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "app-network"
  remote_virtual_network_id = module.secure-network.vnet_id
}
