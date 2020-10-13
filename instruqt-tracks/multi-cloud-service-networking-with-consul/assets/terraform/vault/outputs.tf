output "aws_vault_ip" {
  value = aws_instance.vault.public_ip
}

output "azure_vault_ip" {
  value = azurerm_public_ip.vault.ip_address
}
