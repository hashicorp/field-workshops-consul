# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

path "kv/data/consul"
{
  capabilities = ["read"]
}
path "pki/cert/ca"
{
  capabilities = ["read"]
}
path "consul/creds/agent"
{
  capabilities = ["read"]
}
