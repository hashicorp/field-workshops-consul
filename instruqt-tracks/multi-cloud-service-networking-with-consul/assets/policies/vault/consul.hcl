# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

path "kv/data/consul"
{
  capabilities = ["read"]
}
path "pki/issue/consul"
{
  capabilities = ["read","update"]
}
path "pki/cert/ca"
{
  capabilities = ["read"]
}
