# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

operator = "read"
agent_prefix "" {
  policy = "read"
}
key_prefix "consul-esm/" {
  policy = "write"
}
service_prefix "" {
  policy = "write"
}
session_prefix "" {
   policy = "write"
}
node_prefix "" {
  policy = "write"
}
