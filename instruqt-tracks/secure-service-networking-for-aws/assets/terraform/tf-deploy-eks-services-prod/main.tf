# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  hcp_hvn_cidr_block      = data.terraform_remote_state.hcp.outputs.hcp_hvn.cidr_block
  hcp_acl_token_secret_id = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
  hcp_consul_cluster    = data.terraform_remote_state.hcp.outputs.hcp_consul_cluster
  vpc_id                = data.terraform_remote_state.vpc.outputs.eks_prod_aws_vpc_id
  public_subnets        = data.terraform_remote_state.vpc.outputs.eks_prod_public_subnets
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name             = "${var.cluster_id}-${var.env}"
  cluster_version          = "1.21"
  subnets                  = local.public_subnets
  vpc_id                   = local.vpc_id
  wait_for_cluster_timeout = 420

  node_groups = {
    application = {
      name_prefix      = "hashicups"
      instance_types   = ["t3a.medium"]
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
    }
  }
}

module "eks_consul_client" {
  source  = "./modules/hcp-eks-client"

  cluster_id       = local.hcp_consul_cluster.cluster_id
  consul_hosts     = jsondecode(base64decode(local.hcp_consul_cluster.consul_config_file))["retry_join"]
  k8s_api_endpoint = module.eks.cluster_endpoint
  consul_version   = local.hcp_consul_cluster.consul_version

  boostrap_acl_token    = local.hcp_acl_token_secret_id
  consul_ca_file        = base64decode(local.hcp_consul_cluster.consul_ca_file)
  datacenter            = local.hcp_consul_cluster.datacenter
  gossip_encryption_key = jsondecode(base64decode(local.hcp_consul_cluster.consul_config_file))["encrypt"]

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.eks]
}

module "demo_app" {
  source  = "./modules/k8s-demo-app"

  depends_on = [module.eks_consul_client]
}
