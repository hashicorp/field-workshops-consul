---
slug: traffic-management-request-routing
id: bmlhlnkswqaf
type: challenge
title: 'Traffic Management: Request Routing'
teaser: Apply advanced routing patterns
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
Review the routes and apply the routing configuration.  <br>

```
kubectl config use-context k8s1
kubectl apply -f ingress/service-router.yml
```

Reload the App tab to see the application that is now served over the ingress gateway. <br>

```
kubectl exec deploy/consul-ingress-gateway -c ingress-gateway -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."dynamic_route_configs"? | select(. != null)[0]]'
```

You can also inspect the clusters. <br>

```
kubectl exec deploy/consul-ingress-gateway -c ingress-gateway -- wget -qO- 127.0.0.1:19000/clusters
```

In the next few assignments you will test HashiCups and use the traffic management capabilities of Consul to ship a new feature in this application.
