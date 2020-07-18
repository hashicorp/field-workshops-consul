output "resource_group_name" {
  value = azurerm_resource_group.instruqt.name
}

output "resource_group_location" {
  value = azurerm_resource_group.instruqt.location
}

output "shared_svcs_vnet" {
  value = module.shared-svcs-network.vnet_id
}

output "shared_svcs_subnets" {
  value = module.shared-svcs-network.vnet_subnets
}

output "legacy_vnet" {
  value = module.legacy-network.vnet_id
}

output "legacy_subnets" {
  value = module.legacy-network.vnet_subnets
}

output "aks_vnet" {
  value = module.aks-network.vnet_id
}

output "aks_subnets" {
  value = module.aks-network.vnet_subnets
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}
