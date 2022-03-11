---
slug: provision-identities
id: yebkxnxfihde
type: challenge
title: Provision Service & Workload Identities
teaser: Create workload identities for secure introduction
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/iam
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will create trust with various runtime platforms. These identities are required for Vault to securely introduce workloads. <br>

You can read more about the supported Vault authentication mechanisms on the [Vault website](https://www.vaultproject.io/docs/auth). <br>

Inspect the Terraform and create the workload identities. <br>

```
terraform plan
terraform apply -auto-approve
```

In the next assignment you will centralize secrets around these identities.
