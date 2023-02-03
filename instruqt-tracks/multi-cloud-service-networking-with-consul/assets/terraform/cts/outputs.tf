# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "aws_cts_public_ip" {
  value = aws_instance.cts.public_ip
}
