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
  name     = "instruqt-hcs-consul-azure-${random_string.participant.result}"
  location = "East US"
}

module "network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "web-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  subnet_names        = ["Web", "App", "DB"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}
