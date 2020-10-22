provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "azurerm" {
  version = "=2.20.0"
  features {}
}

provider "google" {
  version = "~> 3.3.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

provider "consul" {
  alias      = "aws"
  datacenter = "aws-us-east-1"
}

provider "consul" {
  alias      = "azure"
  datacenter = "azure-west-us-2"
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}
