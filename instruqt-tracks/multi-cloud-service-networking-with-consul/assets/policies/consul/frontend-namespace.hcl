# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

Name = "payments"
Description = "namespace for payments team"
ACLs {
  PolicyDefaults = [
    {
      Name = "cross-namespace-policy-sd"
    }
  ]
  RoleDefaults = []
}
