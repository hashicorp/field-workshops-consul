

# output "resource_group_name" {
#   value = azurerm_resource_group.consulnetworkautomation
  
# }
output "shared_network_vnet" {
  value = module.shared-network.vnet_id
}

output "shared_network_subnets" {
  value = module.shared-network.vnet_subnets
}
output "secure_network_subnets" {
  value = module.secure-network.vnet_subnets
}
output "app_network_subnets" {
  value = module.app-network.vnet_subnets
}

output "shared_network_boundary_subnets" {
  value = module.shared-network.vnet_subnets[0]
}

output "shared_network_vault_subnets" {
  value = module.shared-network.vnet_subnets[1]
}

output "shared_network_consul_subnets" {
  value = module.shared-network.vnet_subnets[2]
}

output "secure_network_vnet" {
  value = module.shared-network.vnet_id
}

output "secure_network_mgmt_subnet" {
  value = module.secure-network.vnet_subnets[2]
}

output "secure_network_public_subnet" {
  value = module.secure-network.vnet_subnets[0]
}

output "secure_network_private_subnet" {
  value = module.secure-network.vnet_subnets[1]
}


output "app_network_vnet" {
  value = module.shared-network.vnet_id
}

output "app_network_web_subnet" {
  value = module.app-network.vnet_subnets[0]
}

output "app_network_app_subnet" {
  value = module.app-network.vnet_subnets[1]
}

output "app_network_db_subnet" {
  value = module.app-network.vnet_subnets[2]
}
