# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
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
