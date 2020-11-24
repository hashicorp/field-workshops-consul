output "azure_consul_public_ip" {
  value = azurerm_public_ip.consul.ip_address
}

output "azure_mgw_public_ip" {
  value = azurerm_public_ip.mgw.ip_address
}
