# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

path "connect-root/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "connect-intermediate*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts"
{
  capabilities = ["create","update","read","sudo"]
}
path "sys/mounts/*"
{
  capabilities = ["create","update","read","sudo"]
}
path "auth/token/lookup" {
  capabilities = ["create","update"]
}
