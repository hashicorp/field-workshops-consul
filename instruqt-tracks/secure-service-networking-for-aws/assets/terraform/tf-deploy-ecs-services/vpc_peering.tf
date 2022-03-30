locals {
  vpc_region            = "us-west-2"
  hvn_region            = "us-west-2"
  cluster_id            = "workshop-hcp-consul"
  hvn_id                = "workshop-hvn"
  hcp_cluster_token_root_token = data.terraform_remote_state.hcp.outputs.hcp_acl_token
  hcp_acl_token_secret_id = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
  hcp_consul_cluster    = data.terraform_remote_state.hcp.outputs.hcp_consul_cluster
  hvn                   = data.terraform_remote_state.hcp.outputs.hcp_hvn
  vpc_id                = data.terraform_remote_state.hcp.outputs.aws_vpc_ecs_id
  private_route_table_ids = data.terraform_remote_state.hcp.outputs.ecs_private_route_table_ids
  private_subnets        = data.terraform_remote_state.hcp.outputs.ecs_private_subnets
  public_route_table_ids = data.terraform_remote_state.hcp.outputs.ecs_public_route_table_ids
  public_subnets        = data.terraform_remote_state.hcp.outputs.ecs_public_subnets
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = local.hvn
  vpc_id             = local.vpc_id
  subnet_ids = concat(
    local.private_subnets,
    local.public_subnets,
  )
  route_table_ids = concat(
    local.private_route_table_ids,
    local.public_route_table_ids,
  )
#  security_group_ids = [data.aws_security_group.vpc_default.id]
}

module "aws_hcp_consul" {
  subnet_ids = concat(
    module.vpc.private_subnets,
    module.vpc.public_subnets,
  )
  route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.public_route_table_ids,
  )
}