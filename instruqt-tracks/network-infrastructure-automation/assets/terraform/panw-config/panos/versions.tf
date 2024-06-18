# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    panos = {
      source = "paloaltonetworks/panos"
    }
  }
  required_version = ">= 0.13"
}
