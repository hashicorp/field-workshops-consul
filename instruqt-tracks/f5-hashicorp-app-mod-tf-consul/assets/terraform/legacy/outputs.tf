output "web_identity_principal_id" {
  value = azurerm_user_assigned_identity.web.principal_id
}

output "app_identity_principal_id" {
  value = azurerm_user_assigned_identity.app.principal_id
}
