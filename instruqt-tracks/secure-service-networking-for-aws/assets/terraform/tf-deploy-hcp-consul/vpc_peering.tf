provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_services" {
  cidr_block = "172.31.0.0/16"
}

data "aws_arn" "vpc_services" {
  arn = aws_vpc.vpc_services.arn
}

resource "hcp_aws_network_peering" "vpc_services" {
  hvn_id              = hcp_hvn.workshop_hvn.hvn_id
  peering_id          = var.peering_id
  peer_vpc_id         = aws_vpc.vpc_services.id
  peer_account_id     = aws_vpc.vpc_services.owner_id
  peer_vpc_region     = data.aws_arn.vpc_services.region
}

resource "hcp_hvn_route" "peer_route" {
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = var.route_id
  destination_cidr = aws_vpc.vpc_services.cidr_block
  target_link      = hcp_aws_network_peering.vpc_services.self_link
}

resource "aws_vpc_peering_connection_accepter" "vpc_services" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services.provider_peering_id
  auto_accept               = true
}