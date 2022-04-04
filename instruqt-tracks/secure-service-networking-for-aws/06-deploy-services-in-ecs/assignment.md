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
- title: App Architecture Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws-eks/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-app-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - ecs
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-ecs-services
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
ECS words go here.

Now we shall write this data to a file as we'll need it later:

```sh
ECS_VPC_ID=`terraform output aws_vpc_ecs_id`
GOSSIP_KEY=`terraform output -raw hcp_consul_config_file | base64 -d | jq -r .encrypt`
CONSUL_ADDR=`terraform output hcp_consul_private_endpoint_url`
ECS_PRIVATE_SUBNETS=`terraform output ecs_private_subnets`
ECS_PUBLIC_SUBNETS=`terraform output ecs_public_subnets`
ACL_TOKEN=`terraform output hcp_acl_token_secret_id`

cat << EOF > /root/config/terraform.tfvars
ecs_vpc_id            = $ECS_VPC_ID
private_subnets_ids   = $ECS_PRIVATE_SUBNETS
public_subnets_ids    = $ECS_PUBLIC_SUBNETS
consul_client_ca_path = "/root/config/hcp_ca.pem"
consul_cluster_addr   = $CONSUL_ADDR
consul_gossip_key     = "$GOSSIP_KEY"
consul_acl_token      = $ACL_TOKEN
EOF

```