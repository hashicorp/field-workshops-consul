provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

resource "hcp_aws_network_peering" "vpc_services" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-peering"
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route" {
  depends_on       = [aws_vpc_peering_connection_accepter.peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${hcp_hvn.workshop_hvn.hvn_id}-peering-route"
  destination_cidr = module.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vpc_services.self_link
}

resource "aws_route" "peering" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

resource "aws_route" "peering2" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}