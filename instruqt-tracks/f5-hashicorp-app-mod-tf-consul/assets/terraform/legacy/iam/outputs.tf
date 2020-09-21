output "web_identity_id" {
  value = azurerm_user_assigned_identity.web.id
}

output "app_identity_id" {
  value = azurerm_user_assigned_identity.app.id
}
