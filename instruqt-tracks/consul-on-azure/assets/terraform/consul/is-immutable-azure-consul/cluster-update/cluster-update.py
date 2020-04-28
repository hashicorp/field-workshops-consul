#!/usr/bin/env python3

import argparse
from math import floor
from threading import Thread

from azure.common.client_factory import get_client_from_cli_profile
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.compute.models import (
    Sku, VirtualMachineScaleSetUpdate,
    VirtualMachineScaleSetVMProtectionPolicy)


class UpdateOperation:
    def __init__(self, args):
        self.compute_client = get_client_from_cli_profile(
            ComputeManagementClient)
        self.resource_group = args.resource_group
        self.vmss_name = args.name
        self.vmss = self.compute_client.virtual_machine_scale_sets.get(
            resource_group_name=self.resource_group,
            vm_scale_set_name=self.vmss_name
        )

    def run(self):
        self.scale_vmss(self.vmss.sku.capacity * 2)
        self.protect_new_instances()
        self.scale_vmss(floor(self.vmss.sku.capacity / 2))
        self.unprotect_instances()

    def scale_vmss(self, num_instances):
        print(f'Scaling VMSS {self.vmss.name} to {num_instances} instances...')

        update_params = VirtualMachineScaleSetUpdate(
            sku=Sku(
                name=self.vmss.sku.name,
                tier=self.vmss.sku.tier,
                capacity=num_instances
            )
        )

        update_oper = self.compute_client.virtual_machine_scale_sets.update(
            resource_group_name=self.resource_group,
            vm_scale_set_name=self.vmss_name,
            parameters=update_params
        )

        update_oper.wait()

        # Replace VMSS object with updated representation.
        self.vmss = update_oper.result()

    def protect_new_instances(self):
        threads = []
        vms = self.compute_client.virtual_machine_scale_set_vms.list(
            resource_group_name=self.resource_group,
            virtual_machine_scale_set_name=self.vmss_name
        )

        for vm in vms:
            if vm.latest_model_applied:
                print(f'Applying scale-in protection to instance {vm.name}...')
                vm.protection_policy = VirtualMachineScaleSetVMProtectionPolicy(
                    protect_from_scale_in=True
                )
                update_oper = self.compute_client.virtual_machine_scale_set_vms.update(
                    resource_group_name=self.resource_group,
                    vm_scale_set_name=self.vmss_name,
                    instance_id=vm.instance_id,
                    parameters=vm
                )

                t = Thread(target=update_oper.wait)
                threads.append(t)
                t.start()

        for thread in threads:
            thread.join()

    def unprotect_instances(self):
        threads = []
        vms = self.compute_client.virtual_machine_scale_set_vms.list(
            resource_group_name=self.resource_group,
            virtual_machine_scale_set_name=self.vmss_name
        )

        for vm in vms:
            if vm.protection_policy is not None:
                print(
                    f'Removing scale-in protection from instance: {vm.name}...')
                vm.protection_policy = VirtualMachineScaleSetVMProtectionPolicy(
                    protect_from_scale_in=False
                )
                update_oper = self.compute_client.virtual_machine_scale_set_vms.update(
                    resource_group_name=self.resource_group,
                    vm_scale_set_name=self.vmss_name,
                    instance_id=vm.instance_id,
                    parameters=vm
                )

                t = Thread(target=update_oper.wait)
                threads.append(t)
                t.start()

        for thread in threads:
            thread.join()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Executes a blue/green update of clustered HashiCorp Consul or Vault in an Azure VM Scale Set')
    parser.add_argument('--resource-group', '-g', dest='resource_group',
                        required=True, help='Name of resource group containing the VM Scale Set.')
    parser.add_argument('--name', '-n', dest='name', required=True,
                        help='Name of the VM Scale Set to upgrade instances in.')
    args = parser.parse_args()

    oper = UpdateOperation(args)
    oper.run()
