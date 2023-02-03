# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "google" {
  version = "4.7.0"
  project = var.gcp_project_id
  region  = "us-central1"
}

provider "azurerm" {
  version = "=2.47.0"
  features {}
}

resource "random_string" "env" {
  length  = 4
  special = false
  upper   = false
  number  = false
}
