// Pin the version
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.43.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.26.0"
    }
  }
  provider_meta "hcp" {
    module_name = "hcp-consul"
  }
}

// Configure the provider
provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

resource "hcp_hvn" "workshop_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "hcp_consul_cluster" "workshop_hcp_consul" {
  hvn_id          = hcp_hvn.workshop_hvn.hvn_id
  cluster_id      = var.cluster_id
  tier            = "development"
  public_endpoint = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.workshop_hcp_consul.id
}
