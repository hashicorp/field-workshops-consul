# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/vpc/terraform.tfstate"
  }
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}
