output "env" {
  value = random_string.env.result
}

output "ssh_key_public_key_openssh" {
  value = tls_private_key.main.public_key_openssh
}

output "aws_ssh_key_name" {
  value = aws_key_pair.demo.key_name
}

output "aws_shared_svcs_vpc" {
  value = module.aws-vpc-shared-svcs.vpc_id
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
