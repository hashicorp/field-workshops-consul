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
      version = "2.15.1"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}

provider "consul" {
  address    = local.hcp_consul_public_endpoint_url
  datacenter = local.consul_datacenter
  token      = local.hcp_acl_token_secret_id
}