---
slug: service-mesh-environment-review
id: 8nmk95wj6ftw
type: challenge
title: Service Mesh - Environment Review
teaser: Learn about HashiCups
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
In this assignment, take a few moments to review the lab and the overall architecture for HashiCups.
You can see the repository for the HashiCups demo application here: https://github.com/hashicorp-demoapp. <br>


You can also view the services already running in your primary Kube cluster. Prometheus will deploy in a future assignment. <br>

Check the first k8s cluster. <br>

```
kubectl config use-context k8s1
kubectl get deployments
kubectl get pods
kubectl get svc
```

Check the second k8s cluster. <br>

```
kubectl config use-context k8s2
kubectl get deployments
kubectl get pods
kubectl get svc
```

In the next few assignments you will validate the Consul deployment.
