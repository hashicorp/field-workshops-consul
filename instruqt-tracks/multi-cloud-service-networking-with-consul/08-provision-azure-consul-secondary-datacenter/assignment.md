---
slug: provision-azure-consul-secondary-datacenter
id: bwhyra8qd1ls
type: challenge
title: Provision Azure Consul Secondary Datacenter
teaser: Run Consul in Azure
tabs:
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/azure-consul-secondary
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
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
difficulty: basic
timelimit: 300
---
In this assignment you will bootstrap the Azure secondary Cluster, validate the health of the server and its connection to the primary.

Inspect the initialization scripts in the CLI or UI.

```
cat scripts/azure_consul_server.sh
cat scripts/azure_mesh_gateway.sh
```

Inspect the Terraform and provision the servers.

```
terraform plan
terraform apply -auto-approve
```

You can monitor the init scripts with the below commands. <br>

* Consul Server - `ssh ubuntu@$(terraform output azure_consul_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* Consul MGW    - `ssh ubuntu@$(terraform output azure_mgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`


Wait for the server to elect a leader (it can take a few minutes for the Azure compute instance to become available).
Replication with the primary will be enabled. <br>

```
consul_api=$(terraform output azure_consul_public_ip)
curl -s -v http://{$consul_api}:8500/v1/status/leader
curl -s -v http://{$consul_api}:8500/v1/acl/replication | jq
```

Check the CA infrastructure for the secondary. Notice the `sec-` prefix for secondary DC. <br>

```
consul_api=$(terraform output azure_consul_public_ip)
curl -s http://${consul_api}:8500/v1/connect/ca/roots | jq '.Roots'
curl -s http://${consul_api}:8500/v1/connect/ca/roots | jq -r '.Roots[0].IntermediateCerts[0]' | openssl x509 -text -noout
```

In the next assignment you will configure the remaining secondary cluster.
