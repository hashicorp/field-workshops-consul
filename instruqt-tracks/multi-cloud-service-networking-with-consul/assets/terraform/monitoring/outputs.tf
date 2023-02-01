# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "aws_jaeger_ip" {
  value = aws_instance.jaeger.public_ip
}
