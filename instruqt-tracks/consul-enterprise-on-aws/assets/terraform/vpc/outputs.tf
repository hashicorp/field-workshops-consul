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

output "backend_vpc" {
  value = module.vpc-backend.vpc_id
}

output "backend_private_route_table_ids" {
  value = module.vpc-backend.private_route_table_ids
}

output "backend_private_subnets" {
  value = module.vpc-backend.private_subnets
}

output "backend_public_subnets" {
  value = module.vpc-backend.public_subnets
}
