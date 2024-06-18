# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

path "kv/data/consul"
{
  capabilities = ["read"]
}
path "consul/creds/vault"
{
  capabilities = ["read"]
}
path "pki/cert/ca"
{
  capabilities = ["read"]
}
path "identity/oidc/token/consul-aws-us-east-1"
{
  capabilities = ["read"]
}
