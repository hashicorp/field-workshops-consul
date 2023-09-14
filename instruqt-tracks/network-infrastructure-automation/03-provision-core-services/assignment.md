---
slug: 3-provision-core-services
id: dlsjgdoiu2ua
type: challenge
title: Provision Core Services
teaser: Provision Vault and Consul using Terraform
notes:
- type: text
  contents: |
    Terraform allows you to document, share, and deploy environments in one workflow by using Infrastructure as Code!
tabs:
- title: Current lab setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/3.NIA-Workshop-Core_Svcs.html
- title: Vault Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/vault
- title: Consul Server Code
  type: code
  hostname: workstation
  path: /root/terraform/consul-server
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
With the VNETs provisioned, you are now ready to deploy Consul, Vault, and a Bastion Host used to access various services in future challenges.

Terraform will be used to provision each resource.

## HashiCorp Vault
Vault is a secrets management solution that we will use to securely store sensitive information such as usernames, passwords, certificates, and tokens.

You can review the Terraform templates used to deploy Vault, in the 'Vault Terraform Code' tab.

When ready, switch to the `Shell` tab and run the following commands:
```
cd /root/terraform/vault
terraform plan
terraform apply -auto-approve
```

## Consul
Let's provision Consul server.<br>
In the `Shell` tab run the following commands.

 ```
 cd /root/terraform/consul-server
 terraform plan
 terraform apply -auto-approve

 ```
