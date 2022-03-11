terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.0.0"
    }
#    consul = {
#      source = "hashicorp/consul"
#      version = "2.14.0"
#    }
  }
}

provider "aws" {
  region = var.vpc_region
  default_tags {
    tags = var.default_tags
  }
}
