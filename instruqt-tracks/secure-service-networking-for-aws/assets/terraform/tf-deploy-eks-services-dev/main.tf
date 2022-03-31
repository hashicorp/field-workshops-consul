locals {
  vpc_region            = "us-west-2"
  hvn_region            = "us-west-2"
  cluster_id            = "workshop-hcp-consul"
  hvn_id                = "workshop-hvn"
  hcp_cluster_token_root_token = data.terraform_remote_state.hcp.outputs.hcp_acl_token
  hcp_acl_token_secret_id = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
  hcp_consul_cluster    = data.terraform_remote_state.hcp.outputs.hcp_consul_cluster
  hvn                   = data.terraform_remote_state.hcp.outputs.hcp_hvn
  vpc_id                = data.terraform_remote_state.hcp.outputs.aws_vpc_eks_dev_id
  public_route_table_ids = data.terraform_remote_state.hcp.outputs.eks_dev_public_route_table_ids
  public_subnets        = data.terraform_remote_state.hcp.outputs.eks_dev_public_subnets
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.43"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }

}

provider "aws" {
  region = local.vpc_region
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "terraform_remote_state" "hcp" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-hcp-consul/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"
#  version = "18.17.1"

  cluster_name    = "${local.cluster_id}-eks-dev"
  cluster_version = "1.21"
  subnets         = local.public_subnets
#  subnet_ids         = local.public_subnets
  vpc_id          = local.vpc_id

  node_groups = {
#  eks_managed_node_groups = {
    application = {
      name_prefix      = "hashicups"
      instance_types   = ["t3a.medium"]
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
    }
  }
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = local.hvn
  vpc_id             = local.vpc_id
  subnet_ids         = local.public_subnets
  route_table_ids    = local.public_route_table_ids
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

module "eks_consul_client" {
  source  = "./modules/hcp-eks-client"
#  version = "~> 0.6.1"

  cluster_id       = local.hcp_consul_cluster.cluster_id
  consul_hosts     = jsondecode(base64decode(local.hcp_consul_cluster.consul_config_file))["retry_join"]
  k8s_api_endpoint = module.eks.cluster_endpoint
  consul_version   = local.hcp_consul_cluster.consul_version

  boostrap_acl_token    = local.hcp_cluster_token_root_token.secret_id
  consul_ca_file        = base64decode(local.hcp_consul_cluster.consul_ca_file)
  datacenter            = local.hcp_consul_cluster.datacenter
  gossip_encryption_key = jsondecode(base64decode(local.hcp_consul_cluster.consul_config_file))["encrypt"]

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.eks]
}

module "demo_app" {
#  source  = "hashicorp/hcp-consul/aws//modules/k8s-demo-app"
#  version = "~> 0.6.1"
  source  = "./modules/k8s-demo-app"

  depends_on = [module.eks_consul_client]
}

output "consul_root_token" {
  value     = local.hcp_acl_token_secret_id
  sensitive = true
}

output "consul_url" {
  value = local.hcp_consul_cluster.public_endpoint ? (
    local.hcp_consul_cluster.consul_public_endpoint_url
    ) : (
    local.hcp_consul_cluster.consul_private_endpoint_url
  )
}

output "kubeconfig_filename" {
  value = abspath(module.eks.kubeconfig_filename)
}

output "hashicups_url" {
  value = module.demo_app.hashicups_url
}

output "next_steps" {
  value = "Hashicups Application will be ready in ~2 minutes. Use 'terraform output consul_root_token' to retrieve the root token."
}
