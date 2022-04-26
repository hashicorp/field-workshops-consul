---
slug: service-mesh-service-discovery
id: 6g4ky4xdgapb
type: challenge
title: 'Service Mesh: Service Discovery'
teaser: Scale up & Scale Down
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
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
Service Discovery is a important component of Service Mesh, and K8s is one of many platforms Consul supports native service discovery.
Understanding of the low level data plane is not required, but it can be helpful to get a deeper understanding of the mesh at work!

When running on K8s, Consul can consume K8s probes to determine if an instance is healthy or not to receive traffic.
You will test this workflow below. <br>

Add add curl to the payments api pods. <br>

```
kubectl config use-context k8s1
kubectl exec deploy/payments-api-v1 -c payments-api -- apk add curl
```

First let's look at the health check on *one* of our payments API pods. It will be passing. <br>

```
kubectl exec deploy/payments-api-v1 -c payments-api -- curl -s 127.0.0.1:8080/actuator/health | jq
```

Check the downstream service view of the payments-api upstream. You will see two services, and their pod IPs.

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters | grep payments-api
```

We can use the chaos library on our payments service to simulate an application failure on one of our payments pods, and then look at its health check.


```
kubectl exec deploy/payments-api-v1 -c payments-api -- curl -s -X POST localhost:8080/actuator/chaosmonkey/enable
sleep 15
```

Check the health check endpoint. <br>

```
kubectl exec deploy/payments-api-v1 -c payments-api -- curl -s 127.0.0.1:8080/actuator/health | jq
```

Check the K8s probe. <br>

```
kubectl get pod --selector=app=payments-api,version=v1 -o json | jq .items[0].status.conditions
```

Check the status in Consul. <br>

```
curl -s http://127.0.0.1:8500/v1/health/checks/payments-api | jq
```

This failure will remove this instance from the data plane. You will see this reflected in Envoy's health flag.
The flag will prevent this instance from receiving traffic, and the value will be `/failed_eds_health` <br>

Check the downstream service for this flag. <br>

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters | grep payments-api
```

Your payments service will now fail.

```
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
--compressed | jq
```

Scale the deployment to bring a heathly instance online, and wait for the pod to start. Consul will transparently shift traffic away from the failed pod.

```
kubectl scale deployment.v1.apps/payments-api-v1 --replicas=2
sleep 60
```

Check the status in Consul. You will two sets of service checks. One of the sets will be healthy. <br>

```
curl -s http://127.0.0.1:8500/v1/health/checks/payments-api | jq
```

Now check the upstream service.

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters | grep payments-api | grep health_flags
```

Try your payments service again. <br>

```
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
--compressed | jq
```

You can run a graceful restart of the deployment to cycle away the bad pod. You can proceed to the next challenge during the rollout.

```
kubectl rollout restart deployment/payments-api-v1
```

You will introduce more advanced traffic management in the next few assignments.
