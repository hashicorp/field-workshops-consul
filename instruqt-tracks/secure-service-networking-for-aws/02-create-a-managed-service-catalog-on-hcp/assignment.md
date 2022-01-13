---
slug: create-a-managed-service-catalog-on-hcp
id: ltqucwm9rxxo
type: challenge
title: Create a managed Service Catalog on HCP
teaser: A short description of the challenge.
notes:
- type: text
  contents: Replace this text with your own text
tabs:
- title: Workshop Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/n8-ssn4aws/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - HCP
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-hcp-consul
- title: code - HCP Config
  type: code
  hostname: shell
  path: /root/config/
- title: code - ecs
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-ecs-services
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 600
---
We're going to use terraform to deploy both HCP Consul and HCP Vault. To do this, first we need to create an HCP account from which we can provision services.

In this section you will use terraform to provision an HCP Consul cluster peered to your Instruqt AWS account.

When you are ready to provision the resources, in the `shell` tab, execute:

```sh
terraform apply -auto-approve
```

HCP Consul generates the cregistration file requires for connecting consul agents to the HCP Consul cluster. To read the consul config file, execute the following command:

```sh
terraform output hcp_consul_config_file | base64 -d | jq
```

Now we shall write this data to a file as we'll need it later:

```sh
terraform output hcp_consul_config_file | base64 -d | jq > /root/config/hcp_client_config.json
```

Now we shall grab the HCP Consul CA for our ECS and EKS deployments:
```sh
terraform output hcp_consul_ca_file | base64 -d > /root/config/hcp_ca.crt
```