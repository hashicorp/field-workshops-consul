---
slug: security-http
id: 4ummrb5qra2x
type: challenge
title: 'Security: HTTP Traffic'
teaser: Apply Layer 7 Intentions
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
In one terminal, start tailing the rbac logs for the public API. <br>

```
kubectl logs -l app=public-api -c envoy-sidecar -f --since=5s | grep rbac
```

Get the gateway IP. <br>

```
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
```

Try a valid path. <br>

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

Try a bad path.

```
curl -s -v http://${ip}:8080/api/bad
```
