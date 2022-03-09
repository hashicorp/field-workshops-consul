---
slug: provision-consul-terminating-gateways
id: zgy6lji1stib
type: challenge
title: Provision Consul Terminating Gateways
teaser: Configure egress traffic for external services
tabs:
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
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

Remember, CTS auto configured the ESM details to the elasticache service's ingress security group rules in the ESM challenge pior exercise. CTS will do the same for the terminating gateways in AWS that you will deploy.  This is so the data plane reachability is available via these Terminating gateways to the elasticache services. In this assignment, watch the change in real time with the below command in one of the shell windows. <br>

```
ssh ubuntu@$(terraform output -state /root/terraform/cts/terraform.tfstate aws_cts_public_ip) 'journalctl -u consul-tf-sync -f'
```

Now continue with the rest of the commands in the other shell window. Start by getting credentials. <br>

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

With the above command running in one shell, inspect the Terraform, and provision the TGWs in the other shell. <br>

```
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

Run the following command to check SGs were updated by CTS. You can also review the log output from the first shell. <br>

```
aws ec2 describe-security-groups --filter Name="group-id",Values="$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)"
```

You should now see an additional address added, and that is the Private IP address of the TGW in AWS that was just provisioned and outputted by terraform. <br>

This is the power of Consul-Terraform-Sync. <br>

In future assignments you will route traffic to Vault, Redis, and Postgres leveraging the TGW in AWS & Azure.
