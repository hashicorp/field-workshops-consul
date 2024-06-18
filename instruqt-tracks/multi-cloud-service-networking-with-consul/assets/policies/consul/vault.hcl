# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

key_prefix "vault/" {
  "policy" = "write"
}
node_prefix "" {
  "policy" = "write"
}
service "vault" {
  "policy" = "write"
}
agent_prefix "" {
  "policy" = "write"
}
session_prefix "" {
  "policy" = "write"
}
