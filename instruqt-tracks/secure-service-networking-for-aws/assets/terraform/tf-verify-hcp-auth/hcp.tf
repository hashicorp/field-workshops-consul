terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.21.1"
    }
  }
}

// Configure the provider
provider "hcp" {}

data "hcp_consul_versions" "default" {}
