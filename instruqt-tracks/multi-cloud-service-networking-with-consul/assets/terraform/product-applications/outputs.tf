# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "azure_product_api_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}
