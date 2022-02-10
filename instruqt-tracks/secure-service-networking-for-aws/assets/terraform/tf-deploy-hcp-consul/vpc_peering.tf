provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

// EKS_DEV <> HVN Peering
resource "hcp_aws_network_peering" "vpc_services_eks_dev" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering"
  peer_vpc_id     = module.vpc_services_eks_dev.vpc_id
  peer_account_id = module.vpc_services_eks_dev.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "eks_dev_peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services_eks_dev.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route_eks_dev" {
  depends_on       = [aws_vpc_peering_connection_accepter.eks_dev_peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering-route"
  destination_cidr = module.vpc_services_eks_dev.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vpc_services_eks_dev.self_link
}

resource "aws_route" "eks_dev_peering" {
  route_table_id            = module.vpc_services_eks_dev.public_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_dev_peer.vpc_peering_connection_id
}

resource "aws_route" "eks_dev_peering2" {
  route_table_id            = module.vpc_services_eks_dev.private_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_dev_peer.vpc_peering_connection_id
}



// EKS_PROD <> HVN Peering
resource "hcp_aws_network_peering" "vpc_services_eks_prod" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering"
  peer_vpc_id     = module.vpc_services_eks_prod.vpc_id
  peer_account_id = module.vpc_services_eks_prod.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "eks_prod_peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services_eks_prod.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route_eks_prod" {
  depends_on       = [aws_vpc_peering_connection_accepter.eks_prod_peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering-route"
  destination_cidr = module.vpc_services_eks_prod.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vpc_services_eks_prod.self_link
}

resource "aws_route" "eks_prod_peering" {
  route_table_id            = module.vpc_services_eks_prod.public_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_prod_peer.vpc_peering_connection_id
}

resource "aws_route" "eks_prod_peering2" {
  route_table_id            = module.vpc_services_eks_prod.private_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_prod_peer.vpc_peering_connection_id
}


#// EKS_DEV <> EKS_PROD Peering
#resource "aws_vpc_peering_connection" "eks_ecs_peering" {
##  peer_owner_id = var.peer_owner_id
#  peer_vpc_id   = module.vpc_services_eks_prod.vpc_id
#  vpc_id        = module.vpc_services_eks_dev.vpc_id
#}
#
#resource "aws_route" "eks2ecs_route" {
#  route_table_id            = module.vpc_services_eks_dev.public_route_table_ids[0]
#  destination_cidr_block    = module.vpc_services_eks_prod.vpc_cidr_block
#  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_dev_peer.vpc_peering_connection_id
#}
#
#resource "aws_route" "ecs2eks_route" {
#  route_table_id            = module.vpc_services_eks_prod.public_route_table_ids[0]
#  destination_cidr_block    = module.vpc_services_eks_dev.vpc_cidr_block
#  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_prod_peer.vpc_peering_connection_id
#}