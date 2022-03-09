---
slug: deploy-payments-applications
id: zpurxket3eu3
type: challenge
title: Deploy Payments Tier
teaser: Run Payments workloads
tabs:
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
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
  path: /root/terraform/nomad-scheduler-services
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
- title: Apps
  type: code
  hostname: cloud-client
  path: /root/apps/nomad
difficulty: basic
timelimit: 300
---
In this assignment you will schedule the payments-api with Nomad.

Run the nomad job.

```
nomad run payments-api.hcl
```

Payments API services should now be running in the cluster.

```
curl -s ${CONSUL_HTTP_ADDR}/v1/health/service/payments-api?passing=true | jq
```

In future assignments you will use these APIs to process payments.
