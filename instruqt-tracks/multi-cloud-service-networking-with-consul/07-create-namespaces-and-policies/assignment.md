---
slug: create-namespaces-and-policies
id: iyxe8utk74fu
type: challenge
title: Create Namespaces & Policies
teaser: Configure multi-tenancy
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Policies
  type: code
  hostname: cloud-client
  path: /root/policies
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
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will create namespaces in Consul for development groups. <br>
Get an operator token. <br>
```
vault login -method=userpass username=admin password=admin
export CONSUL_HTTP_TOKEN=$(vault read -field token consul/creds/operator)
```
Create the namespaces. <br>
```
consul acl policy create -name "cross-namespace-policy-sd" -description "cross-namespace service discovery" -rules @cross-namespace-sd.hcl
consul namespace update -name default -default-policy-name=cross-namespace-policy-sd
consul namespace write payments-namespace.hcl
consul namespace write product-namespace.hcl
consul namespace write frontend-namespace.hcl
```
Create the developer policies and link them to vault roles. <br>
```
consul acl policy create -name "payments-developer-policy" -description "payments devloper" -rules @payments-developer.hcl
consul acl policy create -name "product-developer-policy" -description  "product developer" -rules @product-developer.hcl
consul acl policy create -name "frontend-developer-policy" -description "frontend developer" -rules @frontend-developer.hcl
vault write consul/roles/payments-developer policies=payments-developer-policy ttl=30m
vault write consul/roles/product-developer  policies=product-developer-policy ttl=30m
vault write consul/roles/frontend-developer policies=frontend-developer-policy ttl=30m
```
Dev teams will deploy application workloads to the above namespaces in future assignments.
