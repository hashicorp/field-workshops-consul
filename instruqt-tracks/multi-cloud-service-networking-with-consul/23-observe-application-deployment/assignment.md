---
slug: observe-application-deployment
id: h5yowpd9iamr
type: challenge
title: Observe Application Deployment
teaser: Collect metrics and traces across clouds.
tabs:
- title: Jaeger
  type: service
  hostname: cloud-client
  path: /search?service=public-api
  port: 16686
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
- title: Web App
  type: code
  hostname: cloud-client
  path: /root/app.txt
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will view traces in the Jaeger UI. <br>

Simulate application traffic. <br>

```
kubectl config use-context graphql
endpoint=$(kubectl get svc consul-graphql-graphql-ingress-gateway -o json | jq -r .status.loadBalancer.ingress[0].ip)
curl -s -v http://${endpoint}:8080/api \
  -H 'Accept-Encoding: gzip, deflate, br' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Connection: keep-alive' \
  -H 'DNT: 1' \
  --data-binary '{"query":"{\n  coffees{id,name,price}\n}"}' \
  --compressed | jq
curl -s -v http://${endpoint}:8080/api \
  -H 'Accept-Encoding: gzip, deflate, br' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Connection: keep-alive' \
  -H 'DNT: 1' \
  --data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
  --compressed | jq
```

Review the traces in the Jaeger UI for each cloud.
