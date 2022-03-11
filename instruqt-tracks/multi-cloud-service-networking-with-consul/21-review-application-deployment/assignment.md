---
slug: review-application-deployment
id: p0g390x5vb14
type: challenge
title: Review Application Deployment
teaser: Validate workload configuration
tabs:
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will validate the product DB and access to the payment queue. <br>

Check the DB for available products. <br>

```
export PGPASSWORD=$(terraform output -state /root/terraform/database-services/terraform.tfstate postgres_password)
psql -U postgres \
  -d postgres \
  -h $(terraform output -state /root/terraform/database-services/terraform.tfstate postgres_fqdn) \
  -c 'SELECT * FROM coffees' \
  -a
```

Check the queue for payments (there will be zero keys). <br>

```
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate aws_tgw_public_ip) \
  "redis-cli -h \
  $(terraform output -state /root/terraform/cache-services/terraform.tfstate -json aws_elasticache_cache_nodes | jq -r .[0].address) -p 6379 keys '*'"
```

In the next few assignments you will retrieve products and send payments.
