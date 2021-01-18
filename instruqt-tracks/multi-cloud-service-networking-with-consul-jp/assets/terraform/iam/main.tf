provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "azurerm" {
  version = "=2.20.0"
  features {}
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "azurerm_subscription" "primary" {}
