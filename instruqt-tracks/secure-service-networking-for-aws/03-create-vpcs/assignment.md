---
slug: create-vpcs
id: vwiywo7jpnew
type: challenge
title: Create VPCs
teaser: Now we create the VPCs and peer them with HCP.
notes:
- type: text
  contents: In this challenge we'll create three VPCs and peer each of them with the
    HashiCorp Virtual Network (HVN) so they can communicate with HCP Consul.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - VPC
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-vpc
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 1800
---
In this challenge we are going to create three VPCs, which will be used in the following steps to provision two EKS clusters and one ECS cluster, per the `Infrastructure Overview` diagram.

In addition to creating these VPCs, to ensure that services deployed within them can reach Consul, we shall use AWS VPC Peering to peer the VPCs with the HashiCorp Virtual Network (HVN) and setup the relevant routes between the VPCs and the HVN.

To see on overview of the infrastructure we're going to deploy, execute the following command:

```sh
terraform plan
```

Next we can start the VPC creation, peering, and routing, by executing:

```sh
terraform apply -auto-approve
```

While that's running, take a look at the terraform deployment in `code - VPC`. Note the `routes.tf` to see the interconnectivity configuration.

You may also wish to switch to your **AWS Console** browser tab and navigate to the VPC secion (Type "VPC" in the search tool). From the "VPC Dashboard" you should start to see the VPCs, subnets, routes, etc, being created by the terraform modules.

**NOTE:** this lab is being built in the "us-west-2" region. If you are not seeing resources in AWS Console make sure you have selected `US West (Oregon) us-west-2` in the drop-down menu at the top right of your screen.

When the `terraform apply` is finished click the green *Check* button to progress to the next Instruqt challenge.