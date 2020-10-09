output "resource_group_name" {
  value = azurerm_resource_group.instruqt.name
}

output "resource_group_id" {
  value = azurerm_resource_group.instruqt.id
}

output "resource_group_location" {
  value = azurerm_resource_group.instruqt.location
}

output "vnet" {
  value = module.network.vnet_id
}

output "subnets" {
  value = module.network.vnet_subnets
}

