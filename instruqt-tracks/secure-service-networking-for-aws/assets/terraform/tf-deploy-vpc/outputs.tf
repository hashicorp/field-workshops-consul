# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## EKS Dev

output "eks_dev_aws_vpc_id" {
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

output "eks_dev_private_route_table_ids" {
  value = module.vpc_eks_dev.private_route_table_ids
}

output "eks_dev_public_route_table_ids" {
  value = module.vpc_eks_dev.public_route_table_ids
}

output "eks_dev_default_route_table_id" {
  value = module.vpc_eks_dev.default_route_table_id
}


## EKS Prod

output "eks_prod_aws_vpc_id" {
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

output "eks_prod_private_route_table_ids" {
  value = module.vpc_eks_prod.private_route_table_ids
}

output "eks_prod_public_route_table_ids" {
  value = module.vpc_eks_prod.public_route_table_ids
}

output "eks_prod_default_route_table_id" {
  value = module.vpc_eks_prod.default_route_table_id
}


## ECS Dev

output "ecs_dev_aws_vpc_id" {
  value = module.vpc_ecs_dev.vpc_id
}

output "ecs_dev_vpc_owner_id" {
  value = module.vpc_ecs_dev.vpc_owner_id
}

output "ecs_dev_vpc_cidr_block" {
  value = module.vpc_ecs_dev.vpc_cidr_block
}

output "ecs_dev_private_subnets" {
  value = module.vpc_ecs_dev.private_subnets
}

output "ecs_dev_public_subnets" {
  value = module.vpc_ecs_dev.public_subnets
}

output "ecs_dev_public_route_table_ids" {
  value = module.vpc_ecs_dev.public_route_table_ids
}

output "ecs_dev_private_route_table_ids" {
  value = module.vpc_ecs_dev.private_route_table_ids
}

output "ecs_dev_default_route_table_id" {
  value = module.vpc_ecs_dev.default_route_table_id
}