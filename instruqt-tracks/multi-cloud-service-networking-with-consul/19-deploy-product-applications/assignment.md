---
slug: deploy-product-applications
id: fjlddb42vbss
type: challenge
title: Deploy Product Tier
teaser: Run Product workloads
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
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/product-applications
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will deploy product applications in Azure.

```
terraform plan
terraform apply -auto-approve
```

You can monitor provisioning with the below command: <br>

```
ssh ubuntu@$(terraform output azure_product_api_public_ip) 'tail -f /var/log/cloud-init-output.log'
```

Product API services should now be running in the cluster.

```
consul catalog services -datacenter azure-west-us-2 -namespace=product
```

In future assignments you will use these APIs to process product queries.
