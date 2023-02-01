# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "aws_nomad_server_public_ip" {
  value = aws_instance.nomad.public_ip
}
