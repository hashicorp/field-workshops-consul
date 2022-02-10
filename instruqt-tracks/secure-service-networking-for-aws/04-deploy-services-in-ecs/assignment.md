---
slug: deploy-services-in-ecs
id: belnxxzs06bn
type: challenge
title: Deploy Services in ECS
teaser: A short description of the challenge.
notes:
- type: text
  contents: Replace this text with your own text
tabs:
- title: code - ecs
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-ecs-services
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: code - HCP Config
  type: code
  hostname: shell
  path: /root/config/
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 6000
---
The assignment the participant needs to complete in order to proceed.

You can use any GitHub flavoured markdown.

We're going to use the `terraform.tfvars` generated earlier. You can review the `terraform.tfvars` file in the `conde - HCP Config` tab.

Copy the `terraform.tfvars` file to the ECS deployment directory with the following command:

```sh
cp /root/config/terraform.tfvars .
```

Verify with
```sh
terraform plan
```

Deploy with:
```sh
terraform apply -auto-approve
```
