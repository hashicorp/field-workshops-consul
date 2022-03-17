---
slug: service-mesh-deploy-your-application-stateless
id: kw3bi3smandq
type: challenge
title: Service Mesh - Deploy Your Application - Stateless
teaser: Deploy reactive and API components
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
  path: /root/deployments/v1
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
In this assignment you will deploy the stateless components of your application to the K8s1 cluster. <br>


Now deploy the frontend, public API, payments API, and product API components.

```
kubectl config use-context k8s1
kubectl apply -f v1
```

Wait for the app tier to be ready.

```
kubectl wait pod --for=condition=Ready --selector=app=frontend
kubectl wait pod --for=condition=Ready --selector=app=public-api
kubectl wait pod --for=condition=Ready --selector=app=product-api
kubectl wait pod --for=condition=Ready --selector=app=payments-api,version=v1 --timeout 90s
```

In the next assignment you will test the application, and the connectivity other K8s cluster.
