provider "aws" {
  region  = "us-east-1"
  version = "~> 2.5"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/vpc/terraform.tfstate"
  }
}

module "consul" {
  source = "./is-immutable-aws-consul"

  ami_owner     = "instruqt@hashicorp.com"
  instance_type = "t3.large"

  consul_cluster_version = var.consul_cluster_version
  bootstrap              = var.bootstrap

  key_name    = "instruqt"
  name_prefix = "instruqt"
  vpc_id      = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc
  subnets     = data.terraform_remote_state.vpc.outputs.shared_svcs_private_subnets

  region             = "us-east-1"
  availability_zones = "us-east-1a,us-east-1b,us-east-1c"

  public_ip = false

  consul_nodes     = "3"
  redundancy_zones = false
  performance_mode = false
  enable_snapshots = false

  owner = "instruqt@hashicorp.com"
  ttl   = "-1"

  additional_security_group_ids = [aws_security_group.consul_ssh.id, aws_security_group.consul_lb.id, values(aws_security_group.consul_eks)[*].id]

}
