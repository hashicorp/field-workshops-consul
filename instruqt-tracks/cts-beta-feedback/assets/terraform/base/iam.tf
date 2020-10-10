resource "azurerm_user_assigned_identity" "web" {
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  name = "web"
}

resource "azurerm_user_assigned_identity" "app" {
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  name = "app"
}

resource "azurerm_user_assigned_identity" "db" {
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  name = "web"
}

