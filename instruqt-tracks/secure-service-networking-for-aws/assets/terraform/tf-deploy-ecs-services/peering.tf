## Peering between EKS Dev VPC and ECS Dev VPC

#resource "aws_vpc_peering_connection_accepter" "eks_dev_to_ecs_dev" {
#  vpc_peering_connection_id = hcp_aws_network_peering.ecs_dev_peer.provider_peering_id
#  auto_accept               = true
#}

#resource "aws_vpc_peering_connection" "eks_dev_to_ecs_dev" {
#  peer_owner_id = local.ecs_dev_vpc_owner_id
#  peer_vpc_id   = local.ecs_dev_aws_vpc_id
#  vpc_id        = local.eks_dev_aws_vpc_id
#  auto_accept   = true
#}


resource "aws_vpc_peering_connection" "ecs_dev_to_eks_dev" {
  vpc_id        = local.ecs_dev_aws_vpc_id
  peer_owner_id = local.eks_dev_vpc_owner_id
  peer_vpc_id   = local.eks_dev_aws_vpc_id
  auto_accept   = true
}

# Routes 

resource "aws_route" "eks_dev_to_ecs_dev" {
  count                     = length(local.eks_dev_route_table_ids)
  route_table_id            = local.eks_dev_route_table_ids[count.index]
  destination_cidr_block    = local.ecs_dev_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_dev_to_eks_dev.id
}

resource "aws_route" "ecs_dev_to_eks_dev" {
  count                     = length(local.ecs_dev_route_table_ids)
  route_table_id            = local.ecs_dev_route_table_ids[count.index]
  destination_cidr_block    = local.eks_dev_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_dev_to_eks_dev.id
}
