---
slug: centralize-secrets-in-vault
id: 5zmdtyk1bnqs
type: challenge
title: Centralize Secrets in Vault
teaser: Create trust and seed bootstrap credentials.
tabs:
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
  path: /root/terraform/vault
- title: Vault Setup Script
  type: code
  hostname: cloud-client
  path: /root/terraform/vault/setup_vault.sh
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will centralize secrets in Vault that will be consumed by applications and services across clouds and runtimes. <br>

The Vault servers are now available and the UI can be accessed in the tab. <br>

* AWS Vault - `ssh ubuntu@$(terraform output aws_vault_ip)`
* Azure Vault - `ssh ubuntu@$(terraform output azure_vault_ip)`

Check the replication status. <br>

```
vault read -format=json sys/replication/status | jq
```

Vault replication is configured across AWS & Azure.
See the [documentation](https://www.vaultproject.io/docs/enterprise/replication) for more information about Vault replication. <br>

An admin account in Vault is now available. Use the below command to log in. <br>

```
vault login -method=userpass username=admin password=admin
```

You can also view the [auth methods](https://www.vaultproject.io/docs/auth) and [secrets engines](https://www.vaultproject.io/docs/secrets) that are configured for the environments.

```
vault secrets list
vault auth list
```

Inspect the role bindings that are configured for the Consul server infrastructure.

```
vault read /auth/aws/role/consul
vault read /auth/azure/role/consul
```

Now that the configuration is valid, seed the initial secret for Consul.

```
vault kv put kv/consul \
  master_token=$(cat /proc/sys/kernel/random/uuid) \
  gossip_key=$(consul keygen) \
  ttl=5m
```

Last, configure Vault to support Auto Config in the AWS DC. Auto Config is out of scope for this lab in Azure DC.

```
vault write /auth/aws/config/identity iam_alias=full_arn
vault write identity/oidc/key/consul allowed_client_ids=consul-server-aws-us-east-1
vault write identity/oidc/role/consul-aws-us-east-1 ttl=30m key=consul client_id=consul-server-aws-us-east-1 template='{"consul": {"node_arn": {{identity.entity.aliases.'$(vault auth list -format=json | jq -r '."aws/".accessor')'.name}} } }'
```

**NOTE: IF YOU RECEIVE ERRORS YOU CAN RUN THE FOLLOWING TWO SCRIPTS TO REPAIR YOUR VAULT ENVIRONMENT! THIS SCRIPT IS NOT NEEDED IF YOUR SANDBOX IS WORKING CORRECTLY!!**

```
#reset vault
/root/scripts/reset_vault.sh
/root/scripts/setup_vault.sh

#configure vault
vault login -method=userpass username=admin password=admin
vault kv put kv/consul \
  master_token=$(cat /proc/sys/kernel/random/uuid) \
  gossip_key=$(consul keygen) \
  ttl=5m
vault write /auth/aws/config/identity iam_alias=full_arn
vault write identity/oidc/key/consul allowed_client_ids=consul-server-aws-us-east-1
vault write identity/oidc/role/consul-aws-us-east-1 ttl=30m key=consul client_id=consul-server-aws-us-east-1 template='{"consul": {"node_arn": {{identity.entity.aliases.'$(vault auth list -format=json | jq -r '."aws/".accessor')'.name}} } }'
```

You will tie these tokens to Consul policies in a later assignment.
