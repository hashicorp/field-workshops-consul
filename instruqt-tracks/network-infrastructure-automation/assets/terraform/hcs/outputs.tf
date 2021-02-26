output "consul_url" {
  value       = hcs_cluster.hcs.consul_external_endpoint
  description = "URL of the HCS for Azure Consul Cluster API and UI."
}

output "consul_vnet" {
  value       = hcs_cluster.hcs.vnet_name
  description = "Vnet for the Azure Consul Cluster."
}

output "resource_group_name" {
  value = hcs_cluster.hcs.managed_resource_group_name
  description = "Managed resource group for the Azure Consul Cluster."
}
