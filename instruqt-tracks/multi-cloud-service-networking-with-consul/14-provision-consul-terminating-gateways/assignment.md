---
slug: provision-consul-terminating-gateways
id: 5vd2pd1hhjj4
type: challenge
title: Provision Consul Terminating Gateways
teaser: Configure egress traffic for external services
tabs:
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/add-consul-multi-cloud/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Shell
  type: terminal
  hostname: cloud-client
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
  path: /root/terraform/tgw
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
In this assignment you will provision Consul Terminating Gateways(TGW), and control AWS SGs with Consul CTS.
You can read [the docs](https://www.consul.io/docs/connect/gateways/terminating-gateway) for more information on how TGW works. <br>

First, get credentials. <br>

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
```

We will start provisioning the TGW. Start with the policy. <br>

```
consul acl policy create -name aws-terminating-gateway -rules @/root/policies/consul/aws-tgw.hcl
vault write consul/roles/aws-tgw policies=aws-terminating-gateway
consul acl policy create -name azure-terminating-gateway -rules @/root/policies/consul/azure-tgw.hcl
vault write consul/roles/azure-tgw policies=azure-terminating-gateway
```

Inspect the Terraform, and provision the TGWs. <br>

```
cd /root/terraform/tgw
terraform plan
terraform apply -auto-approve
```

You can monitor provisioning with the below commands: <br>

* AWS TGW - `ssh ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate aws_tgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* Azure TGW - `ssh ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate azure_tgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`

TGW services are healthy in the catalog. <br>

```
consul catalog services -datacenter=aws-us-east-1
consul catalog services -datacenter=azure-west-us-2
```

Finally, just like CTS auto configured the ESM details to the elasticache service's ingress security group rules, CTS will do the same for the terminating gateways in AWS that were just deployed. This is so the data plane reachability is available via these Terminating gateways to the elasticache services <br>

Run the following command to check if that is indeed the case <br>

```
aws ec2 describe-security-groups --filter Name="group-id",Values="$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)"
```
You should now see an additional address added, and that is the Private IP address of the TGW in AWS that was just provisioned and outputted by terraform. <br>

This is the power of Consul-Terraform-Sync. <br>

In future assignments you will route traffic to Vault, Redis, and Postgres leveraging the TGW in AWS & Azure.
