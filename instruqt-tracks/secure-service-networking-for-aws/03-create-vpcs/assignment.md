---
slug: create-vpcs
id: a7wrqx5dznir
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
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws-eks/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
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
timelimit: 600
---
In this challenge we are going to create three VPCs, which will be used in the following steps. In addition to creating the VPCs we shall peer them, using AWS VPC Peering, and setup the relevant routes, to ensure that services deployed in the VOCs can reach Consul.

To see on overview of the infrastructure we're going to deploy, execute the following command:

```sh
terraform plan
```

Next we can start the VPC creation, by executing:

```sh
terraform apply -auto-approve
```

While that's running, take a look at the terraform deployment in `code - VPC`.

When it's finished, click the green *Check* button at the bottom to progress to the next Instruqt challenge.