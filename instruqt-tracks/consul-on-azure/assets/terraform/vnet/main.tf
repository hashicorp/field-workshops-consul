provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "instruqt" {
  name     = "llarsen-instruqt-resources"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "shared-services" {
  name                = "shared-svcs-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network" "frontend" {
  name                = "frontend-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_virtual_network" "backend" {
  name                = " backend-vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location
  address_space       = ["10.3.0.0/16"]
}
