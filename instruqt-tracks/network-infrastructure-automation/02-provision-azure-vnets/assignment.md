---
slug: provision-azure-vnets
id: dwo2s5mw6ona
type: challenge
title: Provision Azure VNETs
teaser: Deploy basic network infrastructure using Terraform
notes:
- type: text
  contents: |
    Setting up your environment... Your Azure account will be ready in ~5 minutes.
    Keep an eye on the bottom right corner to know when you can get started.
tabs:
- title: Current Lab Setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/2.NIA-Workshop-VNETs.html
- title: Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/vnet
- title: Shell
  type: terminal
  hostname: workstation
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
difficulty: basic
timelimit: 3000
---
In this assignment you will provision the VNets in the "Current Lab Setup" tab that will used in the following assignments.

The "Terraform Code" tab contains all of the Infrastructure as Code (IaC) templates used by Terraform to build the VNETs. Feel free to look over the code!

In the `Shell` tab, deploy the Azure VNETs by running the following commands:
```
terraform plan
terraform apply -auto-approve

```

Their CIDR blocks are listed below:
```
shared-svcs-vnet: 10.2.0.0/16
app-vnet: 10.3.0.0/16
```

The subnets created within 'app-vnet' are as follows:
```
MGMT: 10.3.1.0/24
INTERNET: 10.3.2.0/24
DMZ: 10.3.3.0/24
APP: 10.3.4.0/24
```

You will leverage these VNETs in the next few assignments.
