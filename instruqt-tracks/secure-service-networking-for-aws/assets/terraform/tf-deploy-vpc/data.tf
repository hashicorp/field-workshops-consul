# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "terraform_remote_state" "hcp" {
  backend = "local"

  config = {
    path = "/root/terraform/tf-deploy-hcp-consul/terraform.tfstate"
  }
}