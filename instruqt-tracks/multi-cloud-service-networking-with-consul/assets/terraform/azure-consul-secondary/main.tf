provider "azurerm" {
  version = "=2.47.0"
  features {}
}

data "terraform_remote_state" "consul-primary" {
  backend = "local"

  config = {
    path = "../aws-consul-primary/terraform.tfstate"
  }
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

data "azurerm_subscription" "primary" {}
