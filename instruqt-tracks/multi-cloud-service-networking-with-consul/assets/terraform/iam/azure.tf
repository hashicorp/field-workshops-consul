resource "azurerm_user_assigned_identity" "consul" {
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  name = "consul-${data.terraform_remote_state.infra.outputs.env}"
}

resource "azurerm_role_assignment" "consul" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.consul.principal_id
}

resource "azurerm_user_assigned_identity" "product-api" {
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  name = "product-api-${data.terraform_remote_state.infra.outputs.env}"
}

resource "azurerm_role_assignment" "product-api" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.product-api.principal_id
}
