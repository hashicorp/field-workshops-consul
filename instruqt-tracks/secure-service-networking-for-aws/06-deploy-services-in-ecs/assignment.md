---
slug: deploy-services-in-ecs
id: vnf3bam3dtxl
type: challenge
title: Deploy Services in ECS
teaser: A short description of the challenge.
notes:
- type: text
  contents: Replace this text with your own text
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws-eks/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - ECS
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-ecs-services-dev
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
# Deploy the HashiCups Frontend and Public API

We are going to deploy these two internet facing services onto the ECS platform using terraform. Execute `terraform plan` and review the infrastructure you will create:

```sh
terraform plan
```

When ready, deploy this infrastructure with:

```sh
terraform apply -auto-approve
```

Open the link HashiCups URL in the terraform output. Note that the app does not work - only the front-end loads. This is because the service mesh behind the font-end adheres to Zero Trust Service Networking principles, and applies them both within a single platform, as we saw with k8s, and across platforms, as we see now for cross platform communications between ECS and EKS.

To enable this Securie Service Networking we must specify cross-partition 'Intentions' - rules that determin which service can reach what.

In the Consul Web Interface, navigate to the Intenions section. We are going to create two intentions:
1) allow the public-api service to communicate with the products-api service.
2) allow the public-api service to communicate with the payments service.


# Allow public-api to reach products-api

1) Click "Create"
2) On the left (source) select:
   1) Service: "public-api"
   2) Namespace: "default"
   3) Partition: "ecs-dev"
3) On the right (desintation) select:
   1) *Type: "product-api"
   2) Namespace: "default"
   3) Partition: "eks-dev"

*The UI does not perform service lookups outside of its partition so you need to know the remote partitions service name.

# Allow public-api to reach payments

1) Click "Create"
2) On the left (source) select:
   1) Service: "public-api"
   2) Namespace: "default"
   3) Partition: "ecs-dev"
3) On the right (desintation) select:
   1) *Type: "payments"
   2) Namespace: "default"
   3) Partition: "eks-dev"

*The UI does not perform service lookups outside of its partition so you need to know the remote partitions service name.


