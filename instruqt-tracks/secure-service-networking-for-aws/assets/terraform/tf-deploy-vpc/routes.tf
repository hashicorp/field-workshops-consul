
#module "aws_hcp_consul" {
#  source  = "hashicorp/hcp-consul/aws"
#  version = "~> 0.6.1"
#
#  hvn                = local.hvn
#  vpc_id             = local.vpc_id
#  subnet_ids         = local.public_subnets
#  route_table_ids    = local.public_route_table_ids
#  security_group_ids = [module.eks.cluster_primary_security_group_id]
#}
locals {
  hvn                   = data.terraform_remote_state.hcp.outputs.hcp_hvn
  ecs_dev_vpc_id        = module.vpc_ecs_dev.vpc_id
  ecs_dev_vpc_owner_id  = module.vpc_ecs_dev.vpc_owner_id
}


### Peering between HCP HVNs and VPCs

resource "aws_vpc_peering_connection_accepter" "hvn" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

resource "hcp_aws_network_peering" "ecs_dev_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.ecs_dev_vpc_id
  peer_account_id = local.ecs_dev_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = local.hvn.hvn_id
}

resource "hcp_aws_network_peering" "eks_dev_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.eks_dev_vpc_id
  peer_account_id = local.eks_dev_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = local.hvn.hvn_id
}

resource "hcp_aws_network_peering" "eks_prod_peer" {
  hvn_id          = local.hvn.hvn_id
  peer_vpc_id     = local.eks_prod_vpc_id
  peer_account_id = local.eks_prod_vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = local.hvn.hvn_id
}


### Routes from VPCs to HCP HVN

locals {
  route_table_ids = concat(module.vpc_ecs_dev.default_route_table_id, module.vpc_eks_dev.default_route_table_id, module.vpc_eks_prod.default_route_table_id)
}
resource "aws_route" "hvn" {
  count                     = length(local.route_table_ids)
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = local.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}


### Routes from HCP HVN to VPCs

resource "hcp_hvn_route" "hvn_to_vpc_ecs_dev" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${hcp_hvn.hvn.hvn_id}-to-vpc_ecs_dev"
  destination_cidr = module.vpc_ecs_dev.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}

resource "hcp_hvn_route" "hvn_to_vpc_eks_dev" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${hcp_hvn.hvn.hvn_id}-to-vpc_eks_dev"
  destination_cidr = module.vpc_eks_dev.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}

resource "hcp_hvn_route" "hvn_to_vpc_eks_prod" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${hcp_hvn.hvn.hvn_id}-to-vpc_eks_prod"
  destination_cidr = module.vpc_eks_prod.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}