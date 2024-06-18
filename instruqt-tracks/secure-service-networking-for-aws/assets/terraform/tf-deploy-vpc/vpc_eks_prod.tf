# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "vpc_eks_prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.eks_prod_vpc_name
  cidr = var.eks_prod_vpc_cidr

  azs             = var.azs
  private_subnets = var.eks_prod_private_subnets
  public_subnets  = var.eks_prod_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}