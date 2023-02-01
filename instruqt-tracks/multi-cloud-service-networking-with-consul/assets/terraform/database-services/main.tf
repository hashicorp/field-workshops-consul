# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=2.92.0"
  features {}
}

provider "consul" {
  address    = var.consul_http_addr
  datacenter = "azure-west-us-2"
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
