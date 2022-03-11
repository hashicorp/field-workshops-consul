---
slug: test-application-deployment
id: vot20dcn1tnu
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
In this assignment you will test the application. <br>

View the text file where you can find the application and API endpoints you have deployed. You can also see this file in the `Web App` tab. <br>

Navigate to the frontend of HashiCups, and check out the GraphQL playground for the API. Click on the links in the echoed commands to view the app through a browser. <br>

```
echo "APP URL: http://$(kubectl --context react get svc nginx-ingress-controller -o json | jq -r .status.loadBalancer.ingress[0].ip)"
echo "API URL: http://$(kubectl --context graphql get svc consul-graphql-graphql-ingress-gateway -o json | jq -r .status.loadBalancer.ingress[0].ip):8080"
```

*Optional* - Try the below GraphQL Query in the playground. You can paste in the left side of the window and press the play button!

```
query GetCoffees { coffees { id name image __typename } }
```

Now, let's hit the API directly using cURL.  Monitor the cache for incoming payments in one window. <br>

```
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -state /root/terraform/tgw/terraform.tfstate aws_tgw_public_ip) \
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
