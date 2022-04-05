---
slug: create-vpcs
id: a7wrqx5dznir
type: challenge
title: Create VPCs
teaser: A short description of the challenge.
notes:
- type: text
  contents: Replace this text with your own text
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws-eks/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: App Architecture Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws-eks/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-app-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - VPC
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-vpc
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 600
---
In this challenge we are going to create VPCs that will be used for both developement and prodution deployments across both EKS (Elastic K8s Service) and ECS (Elasting Container Service).

```sh
terraform plan
```

```sh
terraform apply -auto-approve
```


Execute the following command to save the environment variabled for our ECS cluster:
```sh
cd /root/terraform/tf-deploy-hcp-consul
ECS_VPC_ID=`terraform output aws_vpc_eks_dev_id`
ECS_PRIVATE_SUBNETS=`terraform output eks_dev_private_subnets`
ECS_PUBLIC_SUBNETS=`terraform output eks_dev_public_subnets`

cat << EOF > /root/config/vpc.tfvars
ecs_vpc_id            = $ECS_VPC_ID
private_subnets_ids   = $ECS_PRIVATE_SUBNETS
public_subnets_ids    = $ECS_PUBLIC_SUBNETS
EOF
```