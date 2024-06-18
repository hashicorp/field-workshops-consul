# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  hvn                       = data.terraform_remote_state.hcp.outputs.hcp_hvn
  ecs_dev_vpc_id            = module.vpc_ecs_dev.vpc_id
  ecs_dev_vpc_owner_id      = module.vpc_ecs_dev.vpc_owner_id
  ecs_dev_route_table_ids   = concat(module.vpc_ecs_dev.private_route_table_ids, module.vpc_ecs_dev.public_route_table_ids)
  eks_dev_vpc_id            = module.vpc_eks_dev.vpc_id
  eks_dev_vpc_owner_id      = module.vpc_eks_dev.vpc_owner_id
  eks_dev_route_table_ids   = concat(module.vpc_eks_dev.private_route_table_ids, module.vpc_eks_dev.public_route_table_ids)
  eks_prod_vpc_id           = module.vpc_eks_prod.vpc_id
  eks_prod_vpc_owner_id     = module.vpc_eks_prod.vpc_owner_id
  eks_prod_route_table_ids  = concat(module.vpc_eks_prod.private_route_table_ids, module.vpc_eks_prod.public_route_table_ids)
}


## Peering between HCP HVNs and VPCs

### HCP HVN to ECS Dev

resource "aws_vpc_peering_connection_accepter" "hvn_to_ecs_dev" {
  vpc_peering_connection_id = hcp_aws_network_peering.ecs_dev_peer.provider_peering_id
  auto_accept               = true
}

resource "hcp_aws_network_peering" "ecs_dev_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.ecs_dev_vpc_id
  peer_account_id = local.ecs_dev_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = "${local.hvn.hvn_id}-to-vpc-ecs-dev"
}

### HCP HVN to EKS Dev

resource "aws_vpc_peering_connection_accepter" "hvn_to_eks_dev" {
  vpc_peering_connection_id = hcp_aws_network_peering.eks_dev_peer.provider_peering_id
  auto_accept               = true
}

resource "hcp_aws_network_peering" "eks_dev_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.eks_dev_vpc_id
  peer_account_id = local.eks_dev_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = "${local.hvn.hvn_id}-to-vpc-eks-dev"
}

### HCP HVN to EKS Prod

resource "aws_vpc_peering_connection_accepter" "hvn_to_eks_prod" {
  vpc_peering_connection_id = hcp_aws_network_peering.eks_prod_peer.provider_peering_id
  auto_accept               = true
}

resource "hcp_aws_network_peering" "eks_prod_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.eks_prod_vpc_id
  peer_account_id = local.eks_prod_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = "${local.hvn.hvn_id}-to-vpc-eks-prod"
}



## Routes from HCP HVN to VPCs

resource "hcp_hvn_route" "hvn_to_vpc_ecs_dev" {
  hvn_link         = local.hvn.self_link
  hvn_route_id     = "${local.hvn.hvn_id}-to-vpc-ecs-dev"
  destination_cidr = module.vpc_ecs_dev.vpc_cidr_block
  target_link      = hcp_aws_network_peering.ecs_dev_peer.self_link
}

resource "hcp_hvn_route" "hvn_to_vpc_eks_dev" {
  hvn_link         = local.hvn.self_link
  hvn_route_id     = "${local.hvn.hvn_id}-to-vpc-eks-dev"
  destination_cidr = module.vpc_eks_dev.vpc_cidr_block
  target_link      = hcp_aws_network_peering.eks_dev_peer.self_link
}

resource "hcp_hvn_route" "hvn_to_vpc_eks_prod" {
  hvn_link         = local.hvn.self_link
  hvn_route_id     = "${local.hvn.hvn_id}-to-vpc-eks-prod"
  destination_cidr = module.vpc_eks_prod.vpc_cidr_block
  target_link      = hcp_aws_network_peering.eks_prod_peer.self_link
}


## Routes from VPCs to HCP HVN

resource "aws_route" "hvn_to_ecs_dev" {
  count                     = length(local.ecs_dev_route_table_ids)
  route_table_id            = local.ecs_dev_route_table_ids[count.index]
  destination_cidr_block    = local.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.ecs_dev_peer.provider_peering_id
}

resource "aws_route" "hvn_to_eks_dev" {
  count                     = length(local.eks_dev_route_table_ids)
  route_table_id            = local.eks_dev_route_table_ids[count.index]
  destination_cidr_block    = local.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.eks_dev_peer.provider_peering_id
}

resource "aws_route" "hvn_to_eks_prod" {
  count                     = length(local.eks_prod_route_table_ids)
  route_table_id            = local.eks_prod_route_table_ids[count.index]
  destination_cidr_block    = local.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.eks_prod_peer.provider_peering_id
}
