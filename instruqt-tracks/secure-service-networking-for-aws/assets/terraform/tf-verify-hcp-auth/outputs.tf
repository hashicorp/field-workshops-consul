# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hcp_consul_supported_versions" {
  value = data.hcp_consul_versions.default
}