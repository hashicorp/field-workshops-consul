provider "google" {
  version = "~> 3.43.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

provider "azurerm" {
  version = "=2.20.0"
  features {}
}

data "terraform_remote_state" "consul-primary" {
  backend = "local"

  config = {
    path = "../consul-primary/terraform.tfstate"
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
