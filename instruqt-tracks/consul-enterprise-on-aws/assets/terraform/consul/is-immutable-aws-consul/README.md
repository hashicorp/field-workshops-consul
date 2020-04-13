# Deploy Consul to AWS

This folder contains a Terraform module for deploying Consul to AWS (within a VPC). It currently requires the use of CentOS/RHEL 7 but could be adapted to Ubuntu in the Future.

It takes a blue/green approach to managing the Consul ASG deployment while leveraging AutoPilot to support seamless upgrade transitions. It includes health checks to validate consul is healthy before moving to the next phase of deployment. It also blocks changes to the launch configuration unless the version is incremented. This helps version the deployment code and ensure the blue/green pattern is preserved during any changes to the deployment code.  It is very important that the AutoPilot health check works as expected during upgrades, so it would always be good to test changes or upgrades in a development environment first, and ensure you have a recent snapshot to restore to in the event that the active voters are destroyed as a result of faulty health scripts.

The Terraform code will create the following resources in a VPC and subnets that you specify in the designated AWS region:
* IAM instance profile, IAM role, IAM policy, and associated IAM policy documents
* An AWS auto scaling group with 5 EC2 instances running Consul on RHEL 7 or CentOS 7
* An AWS launch configuration tied to the cluster version of Consul.
* An AWS security groups for the Consul EC2 instances.
* Security Group Rules to control ingress and egress for the instances. These attempt to limit most traffic to inside and between the instances, but do allow the following broader access:
   * inbound SSH access on port 22 from anywhere
   * After installation, those broader security group rules could be made tighter.
* S3 Bucket with public ACLs disabled

Additional Components:

* Consul ACL seeds for the various tokens required to protect consul.
* Consul Gossip Encryption Key generation
* Mutual TLS for Consul RPC communication between Consul Servers(wip)
* The AMI is currently automatically setup to consume an AMI built with the corresponding Packer builds within this repository based on filters against the release/owner/name.

You can deploy this in either a public or a private subnet. The VPC should have at least 3 subnets spread across 3 AZs for high availability.

## Preparation
1. On a Linux or Mac system, export your AWS keys as variables. On Windows, you would use set instead of export. You can also export AWS_SESSION_TOKEN if you need to use an MFA token to provision resources in AWS.

```
export AWS_ACCESS_KEY_ID=<your_aws_key>
export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>
export AWS_SESSION_TOKEN=<your_token>
```
2. Copy the file consul.auto.tfvars.example to consul.auto.tfvars and provide appropriate values for the variables.

*NOTE: The below variables can also be supplied via module inputs when consuming as a module.*


`instance_type` should be set to the appropriate EC2 type(m5.large recommended for production).

```
consul_cluster_version
```
This can be used to trigger rolling upgrades of Consul. It's important to increment this value anytime you make changes that would trigger the user_data/ami/launch config values to be updated.

During initial bootstrap you will want this set at 0.0.1, and the bootstrap value set to true. Following the deployment you will need to perform a bootstrap initialization process outlined below.
```
consul_cluster_version = "0.0.1"
bootstrap              = true
```

`key_name` should be the name of an existing AWS keypair in your AWS account in the designated region. Use the name as it is shown in the AWS Console. You need a copy of the corresponding private key on your local workstation.

`name_prefix` should be a name for the environment; they affect the names of some of the resources.

`vpc_id` should be the id of the VPC into which you want to deploy Consul.

`subnets` is a comma separated string of ids for the 3 subnets in your AWS VPC

`avilability_zones` is a comma separated string set to the 3 availability zones where your subnets are located

If using a public subnet, use the following for public_ip:
```
public_ip = true
```

If using a private subnet, use the following for public_ip:
```
public_ip = false
```
However, you will need an additional bastion host deployed within the same VPC to SSH into the Consul nodes.

`consul_nodes` controls the number of consul nodes to deploy (5 recommended unless using redundancy zones below)

`redundancy_zones` (boolean) can be used to enable or disable Consul AutoPilot redundancy zones. There is currently an issue when using RZ in combination with UpgradeMigrations so it's recommended to leave this disabled until that is resolved.

`owner` will be applied to the tags of the instances and needs to match the owner of the AMI built with Packer.

## Deployment
To deploy with Terraform, simply run the following two commands:

```
terraform init
terraform apply
```
When the second command asks you if you want to proceed, type "yes" to confirm.



After successful initial deployment, you need to increment your `consul_cluster_version` variable to 0.0.2 and set `bootstrap` to false, then run an additional `terraform apply`. This will apply the new ACL configuration to the consul server nodes and change the default policy from allow to deny.
```
consul_cluster_version = "0.0.2"
bootstrap              = false
```

```
terraform apply
```

To fully validate the configuration of the consul nodes from a testing perspective it's important to go through 3 versions of deployment(0.0.3) to ensure the ACL configuration is working as expected when new clusters join the old versions.
```
consul_cluster_version = "0.0.3"
bootstrap              = false
```
```
terraform apply
```

## Operations
Any changes to the deployment code or AMI will require that a new `consul_cluster_version` be deployed. The nodes should be treated as immutable, in that changes should not be performed against the local node configuration post-deployment. In order to release new software versions, change local configuration, or install security patches a new AMI should be built via Packer that includes these updates. This AMI change should automatically be picked up and trigger the launch configurations to be updated. The update will block unless the `consul_cluster_version` variable is updated as well to reflect the change. This ensures a safe promotion of new deployment versions (modifications of user_data templates or AMIs).

Any change to the cluster version variables triggers a blue/green replacement of the ASG and corresponding instances ensuring the health of consul before tearing down the old ASG. If the new deployment should fail, the new ASG will be marked as tainted and an additional attempt can be made to update the configuration and do another deploy. After a successful deploy, the old ASG version (and any tainted failed versions) will be destroyed.