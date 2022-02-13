// EKS_PROD <> HVN Peering
resource "hcp_aws_network_peering" "vpc_services_eks_prod" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  peering_id      = "${hcp_hvn.workshop_hvn.hvn_id}-eks-peering-prod"
  peer_vpc_id     = module.vpc_services_eks_prod.vpc_id
  peer_account_id = module.vpc_services_eks_prod.vpc_owner_id
  peer_vpc_region = var.region
}

resource "aws_vpc_peering_connection_accepter" "eks_prod_peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vpc_services_eks_prod.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route_eks_prod" {
  count            = length(module.vpc_eks_prod.public_subnets)
  depends_on       = [aws_vpc_peering_connection_accepter.eks_prod_peer]
  hvn_link         = hcp_hvn.workshop_hvn.self_link
  hvn_route_id     = "${module.vpc_eks_prod.public_subnets[count.index]}-eks-peering-route-prod"
  destination_cidr = module.vpc_eks_prod.public_subnets[count.index].cidr_block
  target_link      = hcp_aws_network_peering.vpc_services_eks_prod.self_link
}

resource "aws_route" "eks_prod_peering" {
  count                     = length(module.vpc_services_eks_prod.public_route_table_ids)
  route_table_id            = module.vpc_services_eks_prod.public_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.workshop_hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eks_prod_peer.vpc_peering_connection_id
}

resource "aws_security_group_rule" "hcp_consul_eks_prod_existing_grp" {
  count             = length(module.vpc_eks_prod.cluster_primary_security_group_id)
  description       = local.hcp_consul_security_groups[count.index].description
  protocol          = local.hcp_consul_security_groups[count.index].protocol
  security_group_id = local.hcp_consul_security_groups[count.index].security_group_id
  cidr_blocks       = [var.hvn.cidr_block]
  from_port         = local.hcp_consul_security_groups[count.index].port
  to_port           = local.hcp_consul_security_groups[count.index].port
  type              = "ingress"
}
