# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "vpc-shared-svcs" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-shared-svcs"

  cidr = "10.1.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public" }

}

module "vpc-frontend" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-frontend"

  cidr = "10.2.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  public_subnets  = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public", "kubernetes.io/cluster/frontend" : "shared", "kubernetes.io/role/elb" : "1" }
  vpc_tags            = { "kubernetes.io/cluster/frontend" : "shared" }
}

module "vpc-backend" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-backend"

  cidr = "10.3.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"]
  public_subnets  = ["10.3.3.0/24", "10.3.4.0/24", "10.3.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public" }
}

module "vpc-storage" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-storage"

  cidr = "10.4.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.4.0.0/24", "10.4.1.0/24", "10.4.2.0/24"]
  public_subnets  = ["10.4.3.0/24", "10.4.4.0/24", "10.4.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public" }
}

/*
module "vpc-storage" {
  providers = {
    aws = aws.west2
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-storage"

  cidr = "10.4.0.0/16"

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  private_subnets = ["10.4.0.0/24", "10.4.1.0/24", "10.4.2.0/24"]
  public_subnets  = ["10.4.3.0/24", "10.4.4.0/24", "10.4.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
}
*/
