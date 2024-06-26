# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "consul_server_ip" {
  value = azurerm_network_interface.consul.private_ip_address
}

output "consul_external_ip" {
  value = azurerm_public_ip.consul.ip_address
}
