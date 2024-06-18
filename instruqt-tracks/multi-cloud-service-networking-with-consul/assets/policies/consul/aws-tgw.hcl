# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

service "aws-us-east-1-terminating-gateway" {
   policy = "write"
}
service "redis" {
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
