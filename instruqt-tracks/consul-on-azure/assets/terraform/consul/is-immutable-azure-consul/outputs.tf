output "consul_asg" {
  value = azurerm_application_security_group.consul_servers.id
}