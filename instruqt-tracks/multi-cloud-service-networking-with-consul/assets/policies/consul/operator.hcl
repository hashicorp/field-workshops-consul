# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

operator = "write"
acl = "write"
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "write"
  intentions = "write"
}
namespace_prefix "" {
  acl = "write"
  service_prefix "" {
    policy = "write"
    intentions = "write"
  }
}
