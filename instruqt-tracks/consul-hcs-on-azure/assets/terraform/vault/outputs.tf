output "vault_lb" {
  value = azurerm_public_ip.vault.ip_address
}

output "vault_ip" {
  value = azurerm_network_interface.vault.private_ip_address
}
