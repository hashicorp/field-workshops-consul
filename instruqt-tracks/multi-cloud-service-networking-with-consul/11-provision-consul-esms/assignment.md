---
slug: provision-consul-esms
id: c3rsgmczwdyb
type: challenge
title: Provision Consul ESMs
teaser: Create health checks for external services
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/esm
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
difficulty: basic
timelimit: 300
---
In this assignment you will provision Consul External Services Monitors (ESMs) to health check services that do not run Consul agents. And control AWS SGs with Consul CTS. <br>

Cloud managed services are common targets for external services monitoring. <br>

You can read more about Consul ESM:
  * https://learn.hashicorp.com/tutorials/consul/service-registration-external-services
  * https://github.com/hashicorp/consul-esm
  * https://www.hashicorp.com/resources/bloomberg-s-consul-story-to-20-000-nodes-and-beyond

Get creds for this operation. <br>

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
```

Create the ESM policy. <br>

```
consul acl policy create -name consul-esm -rules @/root/policies/consul/consul-esm.hcl
vault write consul/roles/esm policies=consul-esm
```

Inspect the Terraform code and provision the external monitoring. <br>

```
terraform plan
terraform apply -auto-approve
```

You can monitor the init scripts with the below commands. <br>
* AWS ESM - `ssh ubuntu@$(terraform output aws_esm_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* Azure ESM - `ssh ubuntu@$(terraform output azure_esm_public_ip) 'tail -f /var/log/cloud-init-output.log'`


ESM services are now available in your Consul datacenters. <br>

```
consul catalog services -datacenter=aws-us-east-1
consul catalog services -datacenter=azure-west-us-2
```
Finally, remember that we setup CTS in the previous assignment? This is so once ESM is deployed, its info is automatically added to the service's 'ingress' security groups rules so it can monitor its health etc. <br>

Run the following command to check if the private IP of ESM that terraform outputed is now in the security group <br>

```
aws ec2 describe-security-groups --filter Name="group-id",Values="$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)"
```

In the next assignments you will provision cloud managed services and configure them for Consul ESM monitoring.
