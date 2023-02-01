# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "lb" {
  value = aws_lb.vault.dns_name
}
