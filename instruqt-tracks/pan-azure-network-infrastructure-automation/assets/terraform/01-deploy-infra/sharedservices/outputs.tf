output "vault_lb" {
  value = azurerm_public_ip.vault.ip_address
}

output "vault_ip" {
  value = azurerm_network_interface.vault.private_ip_address
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

output "logging_ip" {
  value = azurerm_public_ip.logging.ip_address
}

output "consul_lb" {
  value = azurerm_public_ip.consul.ip_address
}
output "consul_ip" {
  value = azurerm_network_interface.consul.private_ip_address
}