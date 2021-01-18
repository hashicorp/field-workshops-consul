output "consul_url" {
  value       = azurerm_managed_application.hcs.outputs["consul_url"]
  description = "URL of the HCS for Azure Consul Cluster API and UI."
}

output "consul_vnet" {
  value       = "${lookup(azurerm_managed_application.hcs.outputs, "vnet_name")}-vnet"
  description = "Vnet for the Azure Consul Cluster."
}

output "resource_group_name" {
  value = azurerm_managed_application.hcs.managed_resource_group_name
}
