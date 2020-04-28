# Deploy Highly-Available Consul Enterprise to Azure

This repository contains a Terraform module which deploys a Consul cluster in highly-available configuration on Microsoft Azure. Consul will be initialized using cloud auto-join.

The module consumer is expected to provide a VNET. In the event a VNET without general-purpose Internet access is provided, the VNET must have a Service Endpoint enabled for `Microsoft.Storage`, and permit outbound access to the `AzureCloud` service tag.

## Virtual Machine Image

Packer configuration and build scripts are provided to create an Azure VM Image containing all necessary tooling. Currently, CentOS 7.x and Red Hat Enterprise Linux 7.x are the only supported distributions.

The following variables are required to execute the Packer build:

| Name | Description |
|------|-------------|
| azure_resource_group_name | Name of an existing Azure resource group in which the VM image will be created. |
| consul_zip | Path to a ZIP file containing the desired Consul Enterprise release. |
| consul_version | String matching the version of Consul deployed in the image. |
| vault_zip | Path to a ZIP file containing the desired Vault Enterprise release. |
| vault_version | String matching the version of Vault deployed in the image. |
| owner | Email address or other identifier of who or what generated the VM image. |
| release | String defining the image release. |

## Terraform Variables

**Required Vairables**

| Name | Type | Description |
|------|------|-------------|
| region | String | The Azure region to deploye resources to. |
| subnet_id | String | Resource ID of an Azure subnet in which deployed instances will operate. |
| ssh_public_key | String | An SSH public key to deploy to all VM instances for the default user. |
| owner | String | Value of the 'Owner' tag on deployed resources. |
| ttl | String | Value of the 'ttl' tag on deployed resources. |
| image_resource_group | String | Name of an Azure Resource Group containing the disk image to launch instances using. |

**Optional Variables - General**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| availability_zones | List(String) | `[]` | List of Azure availability zones to distribute supported resources across. Only available in certain regions. |
| name_prefix | String | `hashicorp` | Prefix used in resource names, alongside a random 8-character identifier. |
| instance_username | String | `azure-user` | Default username to create on VM instances. |
| image_prefix | String | `is-azure-immutable-vault-` | Prefix of the VM image (from Packer) to launch in each VM Scale set. |
| vm_managed_disk_type | String | `Premium_LRS` | Managed disk type to use for VM instances. Must be one of: `Standard_LRS`, `StandardSSD_LRS`, or `Premium_LRS`. |
| use_cloud_init | Boolean | `false` | Whether cloud-init should be used for instance bootstrapping. If `false`, VM Extensions will be used. **Note:** At present, cloud-init does not ensure cluster leadership has successfully transfered before initiating scale-down. Until this is fixed, VM Extensions should be used to initialize instances. |

**Optional Variables - Consul**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| consul_cluster_version | String | `0.0.1` | Custom version tag, used for upgrade migrations. |
| consul_nodes | Number | `5` | Number of Consul server instances to launch. |
| consul_vm_size | String | `Standard_D2s_v3` | The size of VM instance ot use for Consul servers. |
| redundancy_zones | Boolean | `false` | Whether to leverage Redundancy Zones wthin Consul for additional non-voting nodes. |
| bootstrap | Boolean | `true` | Whether the Consul cluster should be deployed in bootstrap configuration. |
| enable_connect | Boolean | `false` | Whether Consul Connect should be enabled in the server configuration. |

## Terraform Outputs

| Name | Description |
|------|-------------|
| consul_asg | ID of the Application Security Group assigned to Consul server instances |

## Cluster Bootstrapping

1) Copy the file consul.auto.tfvars.example to consul.auto.tfvars and provide appropriate values for the included variables. Additional optional configuration options can be found in the tables in the above [Terraform Variables](#terraform-variables) section.

1) Ensure the variable `consul_cluster_version` is set to `0.0.1` and `bootstrap` is set to `true`. These variables are used to trigger blue/green upgrades of the Consul cluster, and control the default ACL policy respectively.

1) Ensure `consul_nodes` is defined with the required number of master nodes to deploy. This defaults to the recommended value of 5 nodes.

1) Initialize Terraform by running `terraform init`, followed by deploying infrastructure using `terraform apply`. After the resources have been deployed, module outputs will display the Azure Resource ID for the Application Security Group all members of the Consul cluster are assigned to. Appropriate rules allowing traffic to the Application Security Groups must be added to a subnet's Network Security Group before any services can accept traffic from outside the containing VNET.

1) Increment the `consul_cluster_version` Terraform variable to `0.0.2` and set the `bootstrap` variable to `false`, then run another `terraform apply`. This will update the Consul configuration to apply ACL enforcement. After the Terraform run has completed, follow the instructions in [Cluster Upgrade](#cluster-upgrade) to perform a blue-green deployment of updated Consul nodes.

## Cluster Upgrade

Due to limitations in Azure VM Scale Sets, we currently rely on an external script to perform cluster upgrade operations. A reference implementation of an upgrade script is provided in `cluster-upgrade/cluster-upgrade.py`.

A pipenv Pipfile is provided with all necessary dependencies. The following directions assume the use of our reference script.

1) Install [Pipenv](https://github.com/pypa/pipenv) to provide for virtual environment creation and dependency retrieval.

1) Navigate to the `cluster-update` directory and run `pipenv install` to initialize the Python virtual environment.

1) Execute `pipenv run ./cluster-update.py --help` to display the script's required variables. At the time of writing, the output is as follows:
```
usage: cluster-update.py [-h] --resource-group RESOURCE_GROUP --name NAME

Executes a blue/green update of clustered HashiCorp Consul or Vault in an
Azure VM Scale Set

optional arguments:
  -h, --help            show this help message and exit
  --resource-group RESOURCE_GROUP, -g RESOURCE_GROUP
                        Name of resource group containing the VM Scale Set.
  --name NAME, -n NAME  Name of the VM Scale Set to upgrade instances in.
```
4) Execute `pipenv run ./cluster-update.py -r <RESOURCE_GROUP_NAME> -n <SCALE_SET_NAME>` to commence the blue-green update operation. The update will perform the following steps:
* Retrieve the current VM Scale Set Configuration.
* Perform a scale-up operation, doubling the current number of instances.
* Wait for all instances to report successful initialization.
  * Consul: Instances report success when all new instances have been made voters, cluster leadership has transfered to an instance in the new group, and voter status is removed from the deposed instances.
  * Vault: Instances report success when the Vault service has successfully started and connected to the storage backend.
* Protect all new instances from scale-in operations.
* Scale the VM Scale Set down to its original size.
* Un-protect the remaining instances from scaling operations.