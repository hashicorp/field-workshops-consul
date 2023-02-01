# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

resource "azurerm_user_assigned_identity" "payments" {
  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name

  name = "payments"
}
