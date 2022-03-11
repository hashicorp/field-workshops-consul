---
slug: provision-nomad-scheduler-services
id: 3gi8yyum3y2f
type: challenge
title: Provision Nomad Scheduler Services
teaser: Deploy Nomad workload infrastructure
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
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
  path: /root/terraform/nomad-scheduler-services
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
difficulty: basic
timelimit: 300
---
In this assignment you will provision Nomad to run payments workloads in AWS.
You can read the docs for more information about the Nomad integrations used in this lab environment: <br>

* [Introduction](https://www.nomadproject.io/intro)
* [Nomad & Vault](https://www.nomadproject.io/docs/integrations/vault-integration)
* [Nomad & Consul](https://www.nomadproject.io/docs/integrations/consul-integration)
* [Nomad & Consul Connect](https://www.nomadproject.io/docs/integrations/consul-connect)

Inspect the Terraform and provision Nomad servers and clients. <br>

```
terraform plan
terraform apply -auto-approve
```

You can monitor provisioning with the below command: <br>

```
ssh ubuntu@$(terraform output aws_nomad_server_public_ip) 'tail -f /var/log/cloud-init-output.log'
```

You can access the Nomad UI at the below URL: <br>

```
echo http://$(terraform output aws_nomad_server_public_ip):4646
```

Nomad services are now running in AWS. <br>

```
consul catalog services -datacenter=aws-us-east-1
```

You will schedule workloads on this nomad cluster in a later assignment.
