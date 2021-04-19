output "consul_server_ip" {
  value = azurerm_network_interface.consulserver-nic.private_ip_address
}