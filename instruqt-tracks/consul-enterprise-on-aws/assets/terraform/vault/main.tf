# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/vpc/terraform.tfstate"
  }
}
