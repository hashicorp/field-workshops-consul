# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

Name = "product"
Description = "namespace for product team"
ACLs {
  PolicyDefaults = [
    {
      Name = "cross-namespace-policy-sd"
    }
  ]
  RoleDefaults = []
}
