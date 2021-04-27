output "consul_server_ip" {
  value = azurerm_network_interface.consulserver-nic.private_ip_address
}

output "consul" {
  value = azurerm_public_ip.consul.ip_address
}
