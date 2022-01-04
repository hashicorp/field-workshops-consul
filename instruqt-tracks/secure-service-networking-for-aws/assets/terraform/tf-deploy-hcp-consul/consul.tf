// Pin the version
terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.21.1"
    }
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