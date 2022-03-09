---
slug: deploy-frontend-applications
id: yxuk0bvy0ypi
type: challenge
title: Deploy Frontend Tier
teaser: Run Frontend workloads
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Helm
  type: code
  hostname: cloud-client
  path: /root/helm
- title: Apps
  type: code
  hostname: cloud-client
  path: /root/apps
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
In this assignment you will deploy frontend applications to the GKE clusters. <br>

Review the k8s deployment specs in the code editor. <br>


Deploy the Public APIs. This API will be exposed via a Consul ingress gateway. <br>

```
kubectl config use-context graphql
kubectl apply -f k8s/public-api
```

Deploy the React Frontend. This frontend will be exposed via an ingress controller with a Connect transparent proxy. <br>

```
kubectl config use-context react
helm install nginx-ingress -f /root/helm/nginx-ingress.yml ingress-nginx/ingress-nginx  --debug --wait
sleep 10
kubectl apply -f k8s/web
```

Frontend services are now available.

```
consul catalog services -datacenter gcp-us-central-1 -namespace=frontend
```

In future assignments you will use these web interfaces and APIs to send traffic to backend application components.
