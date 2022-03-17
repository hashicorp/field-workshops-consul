---
slug: service-mesh-connect-your-runtimes-1
id: yxysb5hrs5gj
type: challenge
title: Service Mesh - Connect Your Runtimes - Part 1
teaser: Connect Stateless K8s Cluster
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
  path: /ui/
  port: 8500
- title: Helm Config
  type: code
  hostname: workstation
  path: /root/helm
- title: Vault UI
  type: service
  hostname: k8s1
  path: /
  port: 8200
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
You can see the complete guide on Kubernetes multi-cluster federation here: https://www.consul.io/docs/k8s/installation/multi-cluster/kubernetes <br>

Start validating Consul on k8s1 with Helm. This cluster that will run our stateless workloads.  <br>

```
kubectl config use-context k8s1
helm status consul
```

Check the pods. <br>

```
kubectl get pods -l app=consul
```

Check the Consul API. <br>

```
curl localhost:8500/v1/status/leader
```

You can also see the Consul UI is now up. <br>

Last, set up the proxy, and mesh defaults for the mesh. <br>

Review the configuration. <br>

```
cat deployments/config/proxy-defaults.yml
cat deployments/config/mesh.yml
```

Apply the config. <br>

```
kubectl apply -f deployments/config/proxy-defaults.yml
kubectl apply -f deployments/config/mesh.yml
```

In the next assignment you will federate with the other K8s clusters.
