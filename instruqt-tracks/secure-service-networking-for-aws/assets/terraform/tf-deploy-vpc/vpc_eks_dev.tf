module "vpc_eks_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.eks_dev_vpc_name
  cidr = var.eks_dev_vpc_cidr

  azs             = var.azs
  private_subnets = var.eks_dev_private_subnets
  public_subnets  = var.eks_dev_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}