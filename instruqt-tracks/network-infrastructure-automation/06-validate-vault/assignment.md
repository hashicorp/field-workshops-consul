---
slug: validate-vault
id: l6orpveiedpr
type: challenge
title: Validate Vault & Consul
teaser: Verify Vault, and Consul are operational
notes:
- type: text
  contents: |
    Next we shall verify the core services are operating as expected.
tabs:
- title: Current lab setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/6.NIA-Workshop-Tokens.html
- title: Shell
  type: terminal
  hostname: workstation
- title: Consul
  type: service
  hostname: workstation
  path: /
  port: 8500
- title: Vault
  type: service
  hostname: workstation
  path: /
  port: 8200
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
difficulty: basic
timelimit: 3000
---
Consul and Vault should now be provisioned and accessible from the corresponding tabs.


In the `Shell` tab run the following commands, use the token and try to access secret/f5 and secret/palo. Access is denied due to escalated privilege requirements.
```
vault login -method=userpass username=operations password=Password1
vault kv get secret/f5
vault kv get secret/pan
```
Now, let's try this again with a user with escalated privilges
```
vault login -method=userpass username=nia password=Password1
vault kv get secret/f5
vault kv get secret/pan
```
Login to the Consul UI and explore to see what services are available if any.

Retrieve the ip address of Consul and Vault (external access)

```
echo $CONSUL_HTTP_ADDR
echo $VAULT_ADDR
```
Consul is not configured with any authentication mechanisms in this Lab. Consul authentication can be activated with ACLs and Vault (Not in scope of this lab)
