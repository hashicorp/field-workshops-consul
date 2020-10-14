provider "google" {
  version = "~> 3.3.0"
  region  = "us-central1"
  project = var.gcp_project_id
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
