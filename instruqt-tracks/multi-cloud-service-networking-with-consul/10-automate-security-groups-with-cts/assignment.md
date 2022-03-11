---
slug: automate-security-groups-with-cts
id: fri1zjookskc
type: challenge
title: Automate Security Groups with CTS
teaser: Use CTS to automate SGs
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
  path: /root/terraform/cts
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
  In this assignment you will provision  Consul-Terraform-Sync
  You can read [the docs](https://www.consul.io/docs/nia) for more information on how to use CTS for Network Infrastructure Automation. <br>

  Get credentials. <br>

  ```
  vault login -method=userpass username=admin password=admin
  export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
  ```

  Next, to start provisioning the CTS instance, store the security group as tfvars file for CTS to use by running the following commands <br>

  ```
  sgid=$(terraform output -state /root/terraform/cache-services/terraform.tfstate elasticache_sg)
  cat << EOF > /root/terraform/cts/security_input.tfvars
  security_group_id="${sgid}"
  EOF
  ```

  Now create the policies for the CTS. <br>

  ```
  consul acl policy create -name cts -rules @/root/policies/consul/cts.hcl
  vault write consul/roles/cts policies=cts
  ```

  Create the CTS instance now <br>

  ```
  cd /root/terraform/cts
  terraform plan
  terraform apply -auto-approve
  ```

  You can monitor provisioning with the below commands <br>

  ```
  ssh ubuntu@$(terraform output -state /root/terraform/cts/terraform.tfstate aws_cts_public_ip) 'tail -f /var/log/cloud-init-output.log'
  ```
  Check if CTS services are healthy in the catalog. <br>

  ```
  consul catalog services -datacenter=aws-us-east-1
  ```

  In the next assignment you will deploy Consul ESM to health check services that do not run Consul agents. More importantly you will notice that CTS, that we just deployed, will automatically add the ESM infra's info to the service's security group so it can start monitoring it. <br>
