// EKS_DEV <> HVN Peering
resource "hcp_aws_network_peering" "vpc_services_eks_dev" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering-dev"
  peer_vpc_id     = module.vpc_services_eks_dev.vpc_id
  peer_account_id = module.vpc_services_eks_dev.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "eks_dev_peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services_eks_dev.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route_eks_dev" {
  count            = length(module.vpc_eks_dev.public_subnets)
  depends_on       = [aws_vpc_peering_connection_accepter.eks_dev_peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${module.vpc_eks_dev.public_subnets[count.index]}-eks-peering-route-dev"
  destination_cidr = module.vpc_eks_dev.public_subnets[count.index].cidr_block
  target_link      = hcp_aws_network_peering.vpc_services_eks_dev.self_link
}

resource "aws_route" "eks_dev_peering" {
  count                     = length(module.vpc_services_eks_dev.public_route_table_ids)
  route_table_id            = module.vpc_services_eks_dev.public_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_dev_peer.vpc_peering_connection_id
}

resource "aws_security_group_rule" "hcp_consul_eks_dev_existing_grp" {
  count             = length(module.vpc_eks_dev.cluster_primary_security_group_id)
  description       = local.hcp_consul_security_groups[count.index].description
  protocol          = local.hcp_consul_security_groups[count.index].protocol
  security_group_id = local.hcp_consul_security_groups[count.index].security_group_id
  cidr_blocks       = [var.hvn.cidr_block]
  from_port         = local.hcp_consul_security_groups[count.index].port
  to_port           = local.hcp_consul_security_groups[count.index].port
  type              = "ingress"
}
