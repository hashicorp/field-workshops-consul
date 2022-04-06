data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "this" {}

data "aws_caller_identity" "current" {}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = data.terraform_remote_state.hcp.outputs.ecs_dev_aws_vpc_id
}

data "terraform_remote_state" "hcp" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-hcp-consul/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-vpc/terraform.tfstate"
  }
}