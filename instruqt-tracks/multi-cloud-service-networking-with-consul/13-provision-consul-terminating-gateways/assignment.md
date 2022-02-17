---
slug: provision-consul-terminating-gateways
id: zc97sjhyj4mw
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

Next, start provisioning the CTS instance. Store the security group as tfvars file for CTS to use. <br>

```
sgid=$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)
cat << EOF > /root/terraform/cts/security_input.tfvars
security_group_id="${sgid}"
EOF
```

Create the policies for the CTS. <br>

```
consul acl policy create -name cts -rules @/root/policies/consul/cts.hcl
vault write consul/roles/cts policies=cts
```

Now create the CTS instance. <br>

```
cd /root/terraform/cts
terraform plan
terraform apply -auto-approve
```

Wait for the CTS process to start, and then watch the process in one shell.

```
sleep 60
ssh ubuntu@$(terraform output aws_cts_public_ip) 'journalctl -u consul-tf-sync -f'
```

In the other shell, we will start provisioning the TGW. Start with the policy. <br>

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

* AWS CTS - `ssh ubuntu@$(terraform output -state /root/terraform/cts/terraform.tfstate aws_cts_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* AWS TGW - `ssh ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate aws_tgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`
* Azure TGW - `ssh ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate azure_tgw_public_ip) 'tail -f /var/log/cloud-init-output.log'`

CTS & TGW services are healthy in the catalog. <br>

```
consul catalog services -datacenter=aws-us-east-1
consul catalog services -datacenter=azure-west-us-2
```

You can also see that the AWS SG was updated.

```
aws ec2 describe-security-groups --filter Name="group-id",Values="$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)"
```

In future assignments you will route traffic to Vault, Redis, and Postgres leveraging the TGW in AWS & Azure.
