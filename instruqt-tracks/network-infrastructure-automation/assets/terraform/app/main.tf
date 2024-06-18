# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=3.72.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

data "terraform_remote_state" "bigip" {
  backend = "local"

  config = {
    path = "../bigip/terraform.tfstate"
  }
}
