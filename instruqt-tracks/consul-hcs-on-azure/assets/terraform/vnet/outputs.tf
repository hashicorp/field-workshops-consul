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

output "frontend_vnet" {
  value = module.frontend-network.vnet_id
}

output "frontend_subnets" {
  value = module.frontend-network.vnet_subnets
}

output "backend_vnet" {
  value = module.backend-network.vnet_id
}

output "backend_subnets" {
  value = module.backend-network.vnet_subnets
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

