# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "azurerm" {
  version = "=2.47.0"
  features {}
}

provider "google" {
  version = "4.7.0"
  project = var.gcp_project_id
  region  = "us-central1"
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "azurerm_subscription" "primary" {}
