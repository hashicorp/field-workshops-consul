data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/infra/terraform.tfstate"
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}
