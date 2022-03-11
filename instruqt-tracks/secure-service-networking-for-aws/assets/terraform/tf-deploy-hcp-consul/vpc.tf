provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

module "vpc_eks_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc_eks_dev"
  cidr = "10.0.0.0/16"

#  azs             = ["us-west-2a", "us-west-2b", ""us-west-2c""]
  azs             = ["us-west-2a", "us-west-2b"]
#  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
#  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "vpc_eks_prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc_eks_prod"
  cidr = "10.1.0.0/16"

#  azs             = ["us-west-2a", "us-west-2b", ""us-west-2c""]
  azs             = ["us-west-2a", "us-west-2b"]
#  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
#  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}
