
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


resource "hcp_aws_network_peering" "peer" {
  hvn_id          = local.hvn
  peer_vpc_id     = local.vpc_id
  peer_account_id = local.vpc_owner_id
  peer_vpc_region = local.vpc_region
  peering_id      = local.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "hvn" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

resource "aws_route" "hvn" {
  count                     = length(local.route_table_ids)
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = local.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}

resource "hcp_hvn_route" "hvn" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${hcp_hvn.hvn.hvn_id}-to-vpc"
  destination_cidr = local.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}