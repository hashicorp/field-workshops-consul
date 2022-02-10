provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

// EKS <> HVN Peering
resource "hcp_aws_network_peering" "vpc_services_eks" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering"
  peer_vpc_id     = module.vpc_services_eks.vpc_id
  peer_account_id = module.vpc_services_eks.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "eks_peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services_eks.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route_eks" {
  depends_on       = [aws_vpc_peering_connection_accepter.eks_peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering-route"
  destination_cidr = module.vpc_services_eks.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vpc_services_eks.self_link
}

resource "aws_route" "eks_peering" {
  route_table_id            = module.vpc_services_eks.public_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_peer.vpc_peering_connection_id
}

resource "aws_route" "eks_peering2" {
  route_table_id            = module.vpc_services_eks.private_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_peer.vpc_peering_connection_id
}

