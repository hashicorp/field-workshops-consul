---
slug: provision-cache-services
id: m39l1byvdqro
type: challenge
title: Provision Cache Services
teaser: Deploy managed Cache instances
tabs:
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/cache-services
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
difficulty: basic
timelimit: 300
---
In this assignment you will provision AWS ElastiCache instances to be consumed by the application.
The ElastiCache instances are Redis datastores. <br>

We can use Terraform to configure Consul with the [Consul Provider](https://registry.terraform.io/providers/hashicorp/consul/latest/docs).

Inspect the Terraform, retrieve an operator token, and provision the Cache instances. <br>

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
terraform plan
terraform apply -auto-approve
```

The managed Cache instance will now be available in the catalog.

```
curl -s "${CONSUL_HTTP_ADDR}/v1/health/service/redis?passing=true" | jq
```

You will use the managed Redis instance to process payments in future assignments.
