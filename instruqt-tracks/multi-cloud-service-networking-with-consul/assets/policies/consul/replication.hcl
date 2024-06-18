# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

operator = "write"
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
acl = "write"
service_prefix "" {
  policy = "read"
  intentions = "read"
}
namespace_prefix "" {
  acl = "write"
  service_prefix "" {
    policy = "read"
    intentions = "read"
  }
}
