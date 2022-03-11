---
slug: provision-vault
id: h3fmvvaaoqyz
type: challenge
title: Provision Vault Infrastructure
teaser: Set up Vault Infrastructure and Enable Replication
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/vault
difficulty: basic
timelimit: 300
---
Vault supports cross-site replication. In this assignment you provision Vault infrastructure in AWS & Azure. <br>

Inspect the Terraform code and provision the Vault infrastructure.

```
terraform plan
terraform apply -auto-approve
```

You can monitor the init scripts with the below commands. <br>


* AWS Vault - `ssh ubuntu@$(terraform output aws_vault_ip) 'tail -f /var/log/cloud-init-output.log'`
* Azure Vault - `ssh ubuntu@$(terraform output azure_vault_ip) 'tail -f /var/log/cloud-init-output.log'`

Vault will support secure introduction of non-container Consul infrastructure in the next few assignments.
