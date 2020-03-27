output "shared_svcs_vpc" {
  value = module.vpc-shared-svcs.vpc_id
}

output "shared_svcs_private_route_table_ids" {
  value = module.vpc-shared-svcs.private_route_table_ids
}

output "shared_svcs_private_subnets" {
  value = module.vpc-shared-svcs.private_subnets
}

output "shared_svcs_public_subnets" {
  value = module.vpc-shared-svcs.public_subnets
}

output "frontend_vpc" {
  value = module.vpc-frontend.vpc_id
}

output "frontend_private_route_table_ids" {
  value = module.vpc-frontend.private_route_table_ids
}

output "frontend_private_subnets" {
  value = module.vpc-frontend.private_subnets
}

output "frontend_public_subnets" {
  value = module.vpc-frontend.public_subnets
}

output "api_vpc" {
  value = module.vpc-api.vpc_id
}

output "api_private_route_table_ids" {
  value = module.vpc-api.private_route_table_ids
}

output "api_private_subnets" {
  value = module.vpc-api.private_subnets
}

output "api_public_subnets" {
  value = module.vpc-api.public_subnets
}
