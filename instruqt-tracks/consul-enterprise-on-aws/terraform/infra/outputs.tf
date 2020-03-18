output "shared_svcs_vpc" {
  value       = module.vpc-shared-svcs.vpc_id
}

output "shared_svcs_public_subnets" {
  value       = module.vpc-shared-svcs.public_subnets
}
