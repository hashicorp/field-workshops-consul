# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

namespace "frontend" {
  service_prefix "" {
    policy     = "read"
    intentions = "write"
  }
}
namespace_prefix "" {
  node_prefix "" {
    policy = "read"
  }
  service_prefix "" {
    policy = "read"
  }
  acl = "read"
}
