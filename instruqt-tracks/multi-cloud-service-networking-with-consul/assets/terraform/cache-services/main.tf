provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "consul" {
  address    = var.consul_http_addr
  datacenter = "aws-us-east-1"
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../iam/terraform.tfstate"
  }
}
