output "payments_identity_id" {
  value = azurerm_user_assigned_identity.payments.id
}

output "payments_identity_principal_id" {
  value = azurerm_user_assigned_identity.payments.principal_id
}
