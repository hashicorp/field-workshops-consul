output "env" {
  value = random_string.env.result
}

output "aws_ssh_key_name" {
  value = aws_key_pair.demo.key_name
}

output "aws_shared_svcs_vpc" {
  value = module.aws-vpc-shared-svcs.vpc_id
}

output "aws_shared_svcs_private_subnets" {
  value = module.aws-vpc-shared-svcs.private_subnets
}

output "aws_shared_svcs_public_subnets" {
  value = module.aws-vpc-shared-svcs.public_subnets
}

output "azure_rg_name" {
  value = azurerm_resource_group.instruqt.name
}

output "azure_rg_location" {
  value = azurerm_resource_group.instruqt.location
}

output "azure_shared_svcs_public_subnets" {
  value = module.azure-shared-svcs-network.vnet_subnets
}

output "azure_app_public_subnets" {
  value = module.azure-app-network.vnet_subnets
}

output "gcp_shared_svcs_network_self_link" {
  value = module.gcp-vpc-shared-svcs.network_self_link
}
