output "consul_url" {
  value       = azurerm_managed_application.hcs.outputs["consul_url"]
  description = "URL of the HCS for Azure Consul Cluster API and UI."
}

output "resource_group_name" {
  value = azurerm_managed_application.hcs.managed_resource_group_name
}