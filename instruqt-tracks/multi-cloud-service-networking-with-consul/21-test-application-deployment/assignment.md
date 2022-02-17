---
slug: test-application-deployment
id: ev6w8ahghluj
type: challenge
title: Test Application Deployment
teaser: Put it all together
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
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
  path: /root
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
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/add-consul-multi-cloud/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Web App
  type: service
  hostname: cloud-client
  path: /
  port: 8080
difficulty: basic
timelimit: 300
---
In this assignment you will test the application. <br>

The UI is available on the react cluster. <br>

```
kubectl config use-context react
echo "http://$(kubectl get svc nginx-ingress-controller -o json | jq -r .status.loadBalancer.ingress[0].ip)"
```

Monitor the cache for incoming payments in one window. <br>

```
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -state /root/terraform/infra/terraform.tfstate aws_bastion_ip) \
  "redis-cli -h \
  $(terraform output -state /root/terraform/cache-services/terraform.tfstate -json aws_elasticache_cache_nodes | jq -r .[0].address) -p 6379 MONITOR"
```

In the other window send traffic to the HashiCups public APIs. <br>

```
kubectl config use-context graphql
endpoint=$(kubectl get svc consul-graphql-graphql-ingress-gateway -o json | jq -r .status.loadBalancer.ingress[0].ip)
```

Try the Product API. <br>

```
curl -s -v http://${endpoint}:8080/api \
  -H 'Accept-Encoding: gzip, deflate, br' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Connection: keep-alive' \
  -H 'DNT: 1' \
  --data-binary '{"query":"{\n  coffees{id,name,price}\n}"}' \
  --compressed | jq
```

Try the payment API. <br>

#payments

```
curl -s -v http://${endpoint}:8080/api \
  -H 'Accept-Encoding: gzip, deflate, br' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Connection: keep-alive' \
  -H 'DNT: 1' \
  --data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
  --compressed | jq
```

You just connected the HashiCups app across three clouds!
