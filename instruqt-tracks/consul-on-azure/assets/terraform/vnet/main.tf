provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "instruqt" {
  name     = "llarsen-instruqt-resources"
  location = "East US"
}

module "shared-svcs-network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "shared-svcs-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  subnet_names        = ["Consul", "Vault", "GatewaySubnet"]

  tags = {
    owner = "lance@hashicorp.com"
  }
}

module "frontend-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "frontend-vnet"
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24"]
  subnet_names        = ["aks"]

  tags = {
    owner = "lance@hashicorp.com"
  }
}

module "backend-network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.instruqt.name
  vnet_name           = "backend-vnet"
  address_space       = "10.3.0.0/16"
  subnet_prefixes     = ["10.3.0.0/24"]
  subnet_names        = ["aks"]

  tags = {
    owner = "lance@hashicorp.com"
  }
}
