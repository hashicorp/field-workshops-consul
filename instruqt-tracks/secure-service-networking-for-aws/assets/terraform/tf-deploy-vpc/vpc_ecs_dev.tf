module "vpc_ecs_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.ecs_dev_vpc_name
  cidr = var.ecs_dev_vpc_cidr

  azs             = var.azs
  private_subnets = var.ecs_dev_private_subnets
  public_subnets  = var.ecs_dev_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}