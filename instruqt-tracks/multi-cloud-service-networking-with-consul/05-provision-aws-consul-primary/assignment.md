---
slug: provision-aws-consul-primary
id: h2ityzcif2bv
type: challenge
title: Provision AWS Consul Primary Datacenter
teaser: Run Consul in AWS
tabs:
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/aws-consul-primary
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Shell
  type: terminal
  hostname: cloud-client
difficulty: basic
timelimit: 14400
---
In this assignment you will bootstrap the initial cluster and validate the health of the server.
The primary Consul server cluster resides in AWS. <br>

Inspect the initialization scripts in the CLI or UI.

```
cat scripts/aws_consul_server.sh
cat scripts/aws_mesh_gateway.sh
```

Inspect the Terraform and provision the servers.

```
terraform plan
terraform apply -auto-approve
```

You can monitor the init scripts with the below commands. <br>

**NOTE: YOU WILL SEE SECRETS ERRORS ON THE MGW. THIS IS OKAY!** <br>


* Consul Server - `ssh ubuntu@$(terraform output aws_consul_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* Consul MGW - `ssh ubuntu@$(terraform output aws_mgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`

Wait for the server to elect a leader (it can take a few minutes for the EC2 instance to become available). <br>

```
consul_api=$(terraform output aws_consul_public_ip)
curl -s -v http://{$consul_api}:8500/v1/status/leader
```

In the next assignment you will finish configuring the Consul primary server.
