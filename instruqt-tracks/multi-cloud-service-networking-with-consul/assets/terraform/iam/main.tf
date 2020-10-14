provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}
