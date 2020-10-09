resource "azurerm_user_assigned_identity" "web" {
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  name = "web"
}

resource "azurerm_user_assigned_identity" "app" {
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  name = "app"
}

resource "azurerm_user_assigned_identity" "db" {
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  name = "web"
}

