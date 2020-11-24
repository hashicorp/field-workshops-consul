resource "azurerm_resource_group" "instruqt" {
  name     = "instruqt-${random_string.env.result}"
  location = "West US 2"
}

module "azure-shared-svcs-network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "shared-svcs-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.0.0/24"]
  subnet_names        = ["shared"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

module "azure-app-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "app-vnet"
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24"]
  subnet_names        = ["app"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}

resource "azurerm_virtual_network_peering" "shared-to-app" {
  name                      = "SharedToApp"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "shared-svcs-vnet"
  remote_virtual_network_id = module.azure-app-network.vnet_id
}

resource "azurerm_virtual_network_peering" "app-to-shared" {
  name                      = "AppToShared"
  resource_group_name       = azurerm_resource_group.instruqt.name
  virtual_network_name      = "app-vnet"
  remote_virtual_network_id = module.azure-shared-svcs-network.vnet_id
}
