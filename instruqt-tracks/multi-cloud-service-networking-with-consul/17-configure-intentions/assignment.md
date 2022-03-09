---
slug: configure-intentions
id: tpxqkg8ssvwr
type: challenge
title: Configure Intentions
teaser: Allow selective mTLS between workloads
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
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
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/policies
difficulty: basic
timelimit: 300
---
In this assignment you will log in as each persona and configure intentions for self-service access.

Allow least privilege access to shared services as an infrastructure operator.

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
consul intention create -allow '*/*' 'default/vault'
consul intention create -allow 'default/payments-api' 'default/redis'
consul intention create -allow 'frontend/public-api' 'default/payments-api'
consul intention create -allow 'product/*' 'default/postgres'
```

As a product developer grant access to frontend team APIs to connect to product services.

```
vault login -method=userpass username=product-developer password=product
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/product-developer)
consul intention create -allow 'frontend/public-api' 'product/product-api'
```

As a frontend developer, you will manage intentions with CRDs in a later exercise.

In later assignments you will use these clusters to run frontend application workloads.
