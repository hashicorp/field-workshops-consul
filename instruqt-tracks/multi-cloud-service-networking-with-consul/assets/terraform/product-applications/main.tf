provider "azurerm" {
  version = "=2.47.0"
  features {}
}

data "azurerm_subscription" "primary" {}

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

data "terraform_remote_state" "db" {
  backend = "local"

  config = {
    path = "../database-services/terraform.tfstate"
  }
}
