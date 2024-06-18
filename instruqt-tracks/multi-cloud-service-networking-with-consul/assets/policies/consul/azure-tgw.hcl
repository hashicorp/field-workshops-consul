# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

service "azure-west-us-2-terminating-gateway" {
   policy = "write"
}
service "postgres" {
   policy = "write"
}
service "vault" {
   policy = "write"
}
service "" {
   policy = "read"
}
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}
