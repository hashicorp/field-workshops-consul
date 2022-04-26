---
slug: service-mesh-test-your-application
id: bfjma8nf17qp
type: challenge
title: Service Mesh - Test Your Application
teaser: Test your deployment
tabs:
- title: App
  type: service
  hostname: k8s1
  path: /
  port: 8080
  new_window: true
- title: Workstation
  type: terminal
  hostname: workstation
- title: K8s1 - Dashboard Token
  type: code
  hostname: workstation
  path: /root/k8s1-dashboard-token.txt
- title: K8s1 - Dashboard
  type: service
  hostname: k8s1
  path: /api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
  port: 8001
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui/k8s1
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments/v1
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
Your application should now be available. You can quickly test the APIs by exposing the public API as a NodePort services.
NodePort services are uncommon in production, but suitable for dev and test. <br>

First, let's look at the differences for upstream services located in the same k8s1 cluster, and services in a different cluster. <br>

```
kubectl config use-context k8s1
```

Same cluster: Public API <br>
The address will be for a sidecar pod. <br>

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters | grep product
```

External cluster: Payments API <br>
The address will be for the local mesh gateway running in the cluster. <br>

```
kubectl exec deploy/payments-api-v1 -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters | grep payments-queue
```

The gateway will inspect the SNI headers and forward it along to the correct destination.
Inspect the SNI value for this service now. <br>

```
kubectl exec deploy/payments-api-v1 -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."dynamic_active_clusters"? | select(. != null)[1]]'
```

Now that you understand the internals of the cross cluster routing, let's test the application so you can make sure it works. <br>

```
kubectl describe svc consul-ingress-gateway
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
```

Try the product API. <br>

```
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"{\n  coffees{id,name,price}\n}"}' \
--compressed | jq
```

Try the payment API. <br>

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

You should have received a 200 status code from the app API.  <br>

Optionally, you can review the data directly in the storage tier.
There will be at least one payment in the queue after running the above APIs.

Switch to the other K8s cluster. <br>

```
kubectl config use-context k8s2
```

Check the payment queue. <br>

```
kubectl exec statefulset/payments-queue -- redis-cli KEYS '*'
```

Check the database. <br>

```
kubectl exec statefulset/product-db -- env PGPASSWORD=postgres psql -U postgres -d products -c 'SELECT * FROM coffees' -a
```

In the next few assignments you will be introduced to more advanced traffic management patterns.
