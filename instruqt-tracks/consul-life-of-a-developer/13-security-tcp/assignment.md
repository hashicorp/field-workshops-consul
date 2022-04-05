---
slug: security-tcp
id: 52jhymbd7kki
type: challenge
title: 'Security: TCP Traffic'
teaser: Apply Layer 4 Intentions
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: Workstation
  type: terminal
  hostname: workstation
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments
- title: App
  type: service
  hostname: k8s1
  path: /
  port: 8080
  new_window: true
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
Intentions are deny by default in a secure configuration.
Test that in this challenge. <br>

Check the rbac filter. <br>

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."http_filters"? | select(. != null)[0]]'
```

Clear the intentions for the app.

```
kubectl delete -f v1/service-intentions.yml
```

Check the rbac filter. <br>

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."http_filters"? | select(. != null)[0]]'
```

Get the gateway IP. <br>

```
kubectl describe svc consul-ingress-gateway
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
```

Send the payment API. <br>

```
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
--compressed | jq
```

You will see an error. <br>

Add the intentions back <br>

```
kubectl apply -f v1/service-intentions.yml
```

Check the filter.

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."http_filters"? | select(. != null)[0]]'
```

Try the API again to fix the connectivity. You will need to wait a few moments for the change to propagate. <br>

```
sleep 30
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
--compressed | jq
```
