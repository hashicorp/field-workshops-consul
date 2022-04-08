data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "this" {}

data "aws_caller_identity" "current" {}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = data.terraform_remote_state.vpc.outputs.ecs_dev_aws_vpc_id
}

data "aws_security_group" "eks_dev_vpc_default" {
  name   = "default"
  vpc_id = data.terraform_remote_state.vpc.outputs.eks_dev_aws_vpc_id
}

data "terraform_remote_state" "hcp" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-hcp-consul/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "eks_dev" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-eks-services-dev/terraform.tfstate"
  }
}

locals {
  hcp_acl_token_secret_id = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
  hcp_consul_private_endpoint_url = data.terraform_remote_state.hcp.outputs.hcp_consul_private_endpoint_url
  hcp_consul_public_endpoint_url = data.terraform_remote_state.hcp.outputs.hcp_consul_public_endpoint_url
  consul_datacenter = data.terraform_remote_state.hcp.outputs.consul_datacenter
  consul_gossip_key = jsondecode(base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_cluster.consul_config_file))["encrypt"]
  hcp_acl_token     = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id

  ecs_dev_aws_vpc_id = data.terraform_remote_state.vpc.outputs.ecs_dev_aws_vpc_id
  ecs_dev_vpc_owner_id = data.terraform_remote_state.vpc.outputs.ecs_dev_vpc_owner_id
  ecs_dev_vpc_cidr_block = data.terraform_remote_state.vpc.outputs.ecs_dev_vpc_cidr_block
  ecs_dev_default_route_table_id = data.terraform_remote_state.vpc.outputs.ecs_dev_default_route_table_id
  ecs_dev_route_table_ids = concat(data.terraform_remote_state.vpc.outputs.ecs_dev_public_route_table_ids, data.terraform_remote_state.vpc.outputs.ecs_dev_private_route_table_ids)
  ecs_dev_public_route_table_ids = data.terraform_remote_state.vpc.outputs.ecs_dev_public_route_table_ids
  ecs_dev_private_subnets = data.terraform_remote_state.vpc.outputs.ecs_dev_private_subnets
  ecs_dev_public_subnets = data.terraform_remote_state.vpc.outputs.ecs_dev_public_subnets

  eks_dev_aws_vpc_id = data.terraform_remote_state.vpc.outputs.eks_dev_aws_vpc_id
  eks_dev_vpc_owner_id = data.terraform_remote_state.vpc.outputs.eks_dev_vpc_owner_id
  eks_dev_vpc_cidr_block = data.terraform_remote_state.vpc.outputs.eks_dev_vpc_cidr_block
  eks_dev_default_route_table_id = data.terraform_remote_state.vpc.outputs.eks_dev_default_route_table_id
  eks_dev_route_table_ids = concat(data.terraform_remote_state.vpc.outputs.eks_dev_public_route_table_ids, data.terraform_remote_state.vpc.outputs.eks_dev_private_route_table_ids)
  eks_dev_public_route_table_ids = data.terraform_remote_state.vpc.outputs.eks_dev_public_route_table_ids
  eks_dev_public_subnets = data.terraform_remote_state.vpc.outputs.eks_dev_public_subnets

  eks_dev_cluster_primary_security_group_id = data.terraform_remote_state.eks_dev.outputs.eks_dev_cluster_primary_security_group_id
}

