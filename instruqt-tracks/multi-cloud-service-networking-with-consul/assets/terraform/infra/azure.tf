resource "azurerm_resource_group" "instruqt" {
  name     = "instruqt-${random_string.env.result}"
  location = "West US"
}

module "shared-svcs-network" {
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

module "frontend-app" {
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
