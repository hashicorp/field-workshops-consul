---
slug: bootstrap-consul-primary
id: 4hda9xe6kox1
type: challenge
title: Bootstrap Consul Primary Datacenter
teaser: Set up Consul for multi-datacenter
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
  path: /root/terraform/aws-consul-primary
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
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
In this assignment you will finish configuring the primary server
and configure tokens and policies for federated clusters to connect to the primary. <br>

* [Vault CA](https://www.consul.io/docs/connect/ca/vault)
* [Secure Multi DC](https://learn.hashicorp.com/tutorials/consul/access-control-replication-multiple-datacenters)
* [Proxy Defaults](https://www.consul.io/docs/agent/config-entries/proxy-defaults)

The Consul server is now available in the UI. <br>

The Consul server was initialized with a [master token](https://www.consul.io/docs/security/acl/acl-system#builtin-tokens)
to facilitate the bootstrap process. <br>

Log in to Vault and get an admin token to finish setting up the Consul server cluster. <br>

```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault kv get -field master_token kv/consul)
```

Vault can [create short lived tokens](https://www.vaultproject.io/docs/secrets/consul) for Consul access.
Configure that now so we can provide least privilege to operators. <br>

```
AWS_CONSUL_IP=$(terraform output -state /root/terraform/aws-consul-primary/terraform.tfstate aws_consul_public_ip)
consul acl policy create -name operator -rules @/root/policies/consul/operator.hcl
vault secrets enable consul
vault write consul/config/access \
    address=http://${AWS_CONSUL_IP}:8500 \
    token=$(consul acl token create -description 'vault mgmt' -policy-name=global-management -format=json | jq -r '.SecretID')
vault write consul/roles/operator policies=operator ttl=30m
```

You can now request a short lived token to make administrative changes to the cluster. <br>

```
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
consul acl token read -self
```

Add a policy for the Consul agents. <br>

```
consul acl policy create -name agent -rules @/root/policies/consul/agent.hcl
vault write consul/roles/agent policies=agent
```

Add a policy for the mesh gateway so this token is dynamically managed by Vault for Consul.
You may need to wait a minute or so for this to be picked up by the MGW process.

```
consul acl policy create -name mesh-gateway -rules @/root/policies/consul/mesh-gateway.hcl
vault write consul/roles/mgw policies=mesh-gateway
sleep 60
```
You can monitor the MGW with the below commands. <br>

* Consul MGW - `ssh ubuntu@$(terraform output aws_mgw_public_ip) 'journalctl -u consul -f'`

Check out the Consul Auto Config configuration on the Consul Server and an example Consul Client.  The `node_arn` will allow us to get a node identity signed by Vault.

Start with the server. <br>

```
ssh ubuntu@$(terraform output aws_consul_public_ip) 'cat /etc/consul.d/server.json' | jq .auto_config
```

Check the MGW client agent config. <br>

```
ssh ubuntu@$(terraform output aws_mgw_public_ip) 'cat /etc/consul.d/auto.json' | jq
```

Check the MGW client agent node.

```
ssh ubuntu@$(terraform output aws_mgw_public_ip) 'curl -s localhost:8500/v1/agent/self' | jq .Config.NodeName
```

Now review the issued intro token and check that it was signed by Vault. The token will have a 30 min expiry.

```
curl -s $VAULT_ADDR/v1/identity/oidc/.well-known/keys  | jq
ssh ubuntu@$(terraform output aws_mgw_public_ip) 'cat /etc/consul.d/token' | jwt
```

The auto config secrets will be stored in the `data_dir`. These will be auto rotated by the Consul client. <br>

Check the ACL secrets. <br>

```
ssh ubuntu@$(terraform output aws_mgw_public_ip) 'sudo cat /opt/consul/data/auto-config.json' | jq .Config.ACL
```

Check the Gossip Key. <br>

```
ssh ubuntu@$(terraform output aws_mgw_public_ip) 'sudo cat /opt/consul/data/auto-config.json' | jq .Config.Gossip
```

Next, tie the token in Vault to the replication policy so we can establish trust with federated clusters. <br>

```
consul acl policy create -name replication -rules @/root/policies/consul/replication.hcl
vault write consul/roles/replication policies=replication
```

Add an additionally policy for Vault SD for Consul.

```
consul acl policy create -name vault -rules @/root/policies/consul/vault.hcl
vault write consul/roles/vault policies=vault
```

Check the CA infrastructure for the primary. Notice the `pri-` prefix for primary DC. <br>

```
curl -s ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots | jq '.Roots'
curl -s ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots | jq -r '.Roots[0].RootCert' | openssl x509 -text -noout
```

Last, apply defaults for the service mesh that you'll leverage in the last few assignments. <br>

```
consul config write proxy-defaults.hcl
```

In the next few assignments you will connect secondary Consul datacenters to this cluster.
