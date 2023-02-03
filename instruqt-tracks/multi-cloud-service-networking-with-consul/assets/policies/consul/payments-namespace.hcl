# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

Name = "frontend"
Description = "namespace for frontend team"
ACLs {
  PolicyDefaults = [
    {
      Name = "cross-namespace-policy-sd"
    }
  ]
  RoleDefaults = []
}
