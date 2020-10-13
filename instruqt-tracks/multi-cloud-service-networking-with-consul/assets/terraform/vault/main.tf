provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "azurerm" {
  version = "=2.30.0"
  features {}
}

provider "google" {
  version = "~> 3.3.0"
  project = var.gcp_project_id
  region  = "us-central1"
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
