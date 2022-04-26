---
slug: service-mesh-deploy-your-application-stateful
id: fis3ruykqodk
type: challenge
title: Service Mesh - Deploy Your Application -  Stateful
teaser: Deploy Application Storage
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: K8s2 - Dashboard Token
  type: code
  hostname: workstation
  path: /root/k8s2-dashboard-token.txt
- title: K8s2 - Dashboard
  type: service
  hostname: k8s2
  path: /api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
  port: 8001
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui/k8s2
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments/storage
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
In this assignment you will deploy the stateful storage of your application to the K8s2 cluster. <br>

Now deploy the stateful storage components.

```
kubectl config use-context k8s2
kubectl apply -f storage
```

Wait for the storage pods to be ready.

```
kubectl wait pod --selector=app=payments-queue  --for=condition=Ready
kubectl wait pod --selector=app=product-db  --for=condition=Ready
```

In the next assignment you will connect workloads on the other K8s cluster to the deployed storage tier.
