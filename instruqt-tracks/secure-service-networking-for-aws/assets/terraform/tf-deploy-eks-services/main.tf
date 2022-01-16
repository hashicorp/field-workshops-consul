data "aws_availability_zones" "available" {}

#module "vpc" {
#  source  = "terraform-aws-modules/vpc/aws"
#  version = "2.78.0"
#
#  name                 = "${var.cluster_id}-vpc"
#  cidr                 = "10.0.0.0/16"
#  azs                  = data.aws_availability_zones.available.names
#  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#  enable_nat_gateway   = true
#  single_nat_gateway   = true
#  enable_dns_hostnames = true
#}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  cluster_name    = "${data.terraform_remote_state.hcp.outputs.hcp_cluster_id}-eks"
  cluster_version = "1.21"
  subnets         = data.terraform_remote_state.hcp.outputs.public_subnets
  vpc_id          = data.terraform_remote_state.hcp.outputs.aws_vpc_id

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

# The HVN created in HCP
#resource "hcp_hvn" "main" {
#  hvn_id         = var.hvn_id
#  cloud_provider = "aws"
#  region         = var.hvn_region
#  cidr_block     = var.hvn_cidr_block
#}
#
#module "aws_hcp_consul" {
#  source  = "hashicorp/hcp-consul/aws"
#  version = "~> 0.4.2"
#
#  hvn                = hcp_hvn.main
#  vpc_id             = module.vpc.vpc_id
#  subnet_ids         = module.vpc.public_subnets
#  route_table_ids    = module.vpc.public_route_table_ids
#  security_group_ids = [module.eks.cluster_primary_security_group_id]
#}
#
#resource "hcp_consul_cluster" "main" {
#  cluster_id      = var.cluster_id
#  hvn_id          = hcp_hvn.main.hvn_id
#  public_endpoint = true
#  tier            = var.tier
#}
#
#resource "hcp_consul_cluster_root_token" "token" {
#  cluster_id = hcp_consul_cluster.main.id
#}
#
module "eks_consul_client" {
  source  = "hashicorp/hcp-consul/aws//modules/hcp-eks-client"
  version = "~> 0.4.2"

  cluster_id       = data.terraform_remote_state.hcp.outputs.hcp_cluster_id
  consul_hosts     = [substr(data.terraform_remote_state.hcp.outputs.hcp_consul_private_endpoint_url, 8, -1)]
  k8s_api_endpoint = module.eks.cluster_endpoint
#  consul_version   = hcp_consul_cluster.main.consul_version

  boostrap_acl_token    = hcp_consul_cluster_root_token.token.secret_id
  consul_ca_file        = base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_ca_file)
  datacenter            = data.terraform_remote_state.hcp.outputs.consul_datacenter
  gossip_encryption_key = jsondecode(base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_config_file))["encrypt"]

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.eks]
}

module "demo_app" {
  source  = "hashicorp/hcp-consul/aws//modules/k8s-demo-app"
  version = "~> 0.4.2"

  depends_on = [module.eks_consul_client]
}