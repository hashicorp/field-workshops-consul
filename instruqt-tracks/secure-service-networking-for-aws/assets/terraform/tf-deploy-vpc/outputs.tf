## EKS Dev

output "aws_vpc_eks_dev_id" {
  value = module.vpc_eks_dev.vpc_id
}

output "eks_dev_vpc_owner_id" {
  value = module.vpc_eks_dev.vpc_owner_id
}

output "eks_dev_vpc_cidr_block" {
  value = module.vpc_eks_dev.vpc_cidr_block
}

output "eks_dev_private_subnets" {
  value = module.vpc_eks_dev.private_subnets
}

output "eks_dev_public_subnets" {
  value = module.vpc_eks_dev.public_subnets
}

output "eks_dev_public_route_table_ids" {
  value = module.vpc_eks_dev.public_route_table_ids
}



## EKS Prod

output "aws_vpc_eks_prod_id" {
  value = module.vpc_eks_prod.vpc_id
}

output "eks_prod_vpc_owner_id" {
  value = module.vpc_eks_dev.vpc_owner_id
}

output "eks_prod_vpc_cidr_block" {
  value = module.vpc_eks_dev.vpc_cidr_block
}

output "eks_prod_private_subnets" {
  value = module.vpc_eks_prod.private_subnets
}

output "eks_prod_public_subnets" {
  value = module.vpc_eks_prod.public_subnets
}

output "eks_prod_public_route_table_ids" {
  value = module.vpc_eks_prod.public_route_table_ids
}



## ECS Dev

output "aws_vpc_ecs_id" {
  value = module.vpc_ecs_dev.vpc_id
}

output "ecs_vpc_owner_id" {
  value = module.vpc_ecs_dev.vpc_owner_id
}

output "ecs_vpc_cidr_block" {
  value = module.vpc_ecs_dev.vpc_cidr_block
}

output "ecs_private_subnets" {
  value = module.vpc_ecs_dev.private_subnets
}

output "ecs_public_subnets" {
  value = module.vpc_ecs_dev.public_subnets
}

output "ecs_public_route_table_ids" {
  value = module.vpc_ecs_dev.public_route_table_ids
}

output "ecs_private_route_table_ids" {
  value = module.vpc_ecs_dev.private_route_table_ids
}
