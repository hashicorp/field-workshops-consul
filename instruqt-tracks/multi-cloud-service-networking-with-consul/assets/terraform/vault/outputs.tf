output "aws_vault_ip" {
  value = aws_instance.vault.public_ip
}

output "aws_vault_iam_role_arn" {
  value = aws_iam_role.vault.arn
}

output "azure_vault_ip" {
  value = azurerm_public_ip.vault.ip_address
}

output "azure_vault_user_assigned_identity_principal_id" {
  value = azurerm_virtual_machine.vault.identity.0.principal_id
}
