provider "azurerm" {
  version = "=2.13.0"
  features {}
}

resource "random_string" "participant" {
  length = 4
  special = false
  upper = false
  number = false
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
  subnet_prefixes     = ["10.2.0.0/24"]
  subnet_names        = ["Vault"]

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
