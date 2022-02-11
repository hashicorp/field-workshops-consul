terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.21.1"
    }
  }
}

resource "hcp_hvn" "workshop_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

module "aws_hcp_consul-dev" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = hcp_hvn.workshop_hvn
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  route_table_ids    = module.vpc.public_route_table_ids
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

module "aws_hcp_consul-prod" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = hcp_hvn.workshop_hvn
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  route_table_ids    = module.vpc.public_route_table_ids
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

resource "hcp_consul_cluster" "workshop_hcp_consul" {
  cluster_id      = var.cluster_id
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  public_endpoint = true
  tier            = var.tier
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.workshop_hcp_consul.id
}
