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
    consul = {
      source = "hashicorp/consul"
      version = "2.15.0"
    }
  }
}

provider "aws" {
  region = var.vpc_region
  default_tags {
    tags = var.default_tags
  }
}

provider "consul" {
  address    = data.terraform_remote_state.hcp.outputs.hcp_consul_public_endpoint_url
  datacenter = data.terraform_remote_state.hcp.outputs.consul_datacenter
  token      = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
}