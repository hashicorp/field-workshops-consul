---
slug: provision-database-services
id: fl8zngavri4k
type: challenge
title: Provision Database Services
teaser: Deploy managed DB instances
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/database-services
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
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will provision Azure Database Postgres instance to be consumed by the application. <br>

We can use Terraform to configure Consul with the [Consul Provider](https://registry.terraform.io/providers/hashicorp/consul/latest/docs).

Inspect the Terraform, retrieve an operator token, and provision the Database instances. <br>

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
terraform plan
terraform apply -auto-approve
```

The managed database instance will now be available in the catalog.

```
curl -s "${CONSUL_HTTP_ADDR}/v1/health/service/postgres?dc=azure-west-us-2&passing=true" | jq
```

You will use the managed Postgres instance to query available products in future assignments.
