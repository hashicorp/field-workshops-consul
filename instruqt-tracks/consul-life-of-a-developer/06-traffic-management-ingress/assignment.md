---
slug: traffic-management-ingress
id: 91bhavrdjrub
type: challenge
title: 'Traffic Management: Ingress'
teaser: Bring traffic into your mesh
tabs:
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
  path: /root/deployments/ingress
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
Review and apply the ingress config.

```
kubectl config use-context k8s1
kubectl apply -f ingress/hashicups.yml
```

Your ingress config is now in Consul. <br>

```
kubectl describe ingressgateway ingress-gateway
consul config read -kind ingress-gateway -name ingress-gateway | jq
```

In the next assignment you will configure request routing for this ingress gateway.
