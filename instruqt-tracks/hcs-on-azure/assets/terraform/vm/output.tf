# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vm_ip" {
  depends_on = [azurerm_virtual_machine.vm]
  value = "ssh -J azure-user@${data.terraform_remote_state.vnet.outputs.bastion_ip} azure-user@${azurerm_network_interface.vm.private_ip_address}"
}
