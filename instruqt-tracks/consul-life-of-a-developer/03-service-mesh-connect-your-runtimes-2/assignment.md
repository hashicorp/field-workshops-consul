---
slug: service-mesh-connect-your-runtimes-2
id: 7gpp19me4try
type: challenge
title: Service Mesh - Connect Your Runtimes - Part 2s
teaser: Connect Stateful K8s Cluster
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: K8s2 - Dashboard Token
  type: code
  hostname: workstation
  path: /root/k8s2-dashboard-token.txt
- title: K8s2- Dashboard
  type: service
  hostname: k8s2
  path: /api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
  port: 8001
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui/
  port: 8500
- title: Helm Config
  type: code
  hostname: workstation
  path: /root/helm
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 1800
---
In this assignment you will validate the steps in this guide for the secondary cluster: https://www.consul.io/docs/k8s/installation/multi-cluster/kubernetes <br>

Deploy Consul to k8s2 cluster.

```
kubectl config use-context k8s2
helm status consul
```

Check the pods. <br>

```
kubectl get pods -l app=consul
```

Check that the Kubernetes clusters are now federated.

```
consul members -wan
```

In this new few assignments, you will deploy workloads to these clusters.
