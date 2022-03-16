---
slug: observability-metrics
id: 3yb13v3q60lf
type: challenge
title: 'Observability: Metrics'
teaser: Collect Application Metrics
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui/k8s1/services/payments-api
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments/observability
- title: App
  type: service
  hostname: k8s1
  path: /
  port: 8080
  new_window: true
- title: Grafana - UI
  type: service
  hostname: k8s1
  port: 3000
- title: Grafana - Password
  type: code
  hostname: workstation
  path: /tmp/grafana-pass.txt
- title: Prometheus - UI
  type: service
  hostname: k8s1
  path: /targets#job-kubernetes-pods
  port: 9090
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
In this assignment you will run a traffic simulation to create metrics to visualize on the Consul dashboard. <br>

Check that Prometheus is deployed.

```
kubectl get pods --selector app=prometheus
kubectl get svc --selector app=prometheus
```

Redeploy the v2 application with chaos monkey enabled so we can create some errors and latency in the payments tier.
You can scale the v1 deployment at this time as they are no longer needed. <br>

```
kubectl scale deployment.v1.apps/payments-api-v1 --replicas=0
kubectl apply -f observability/payments-api-v2-chaos.yml
sleep 10
kubectl wait pod --for=condition=Ready --selector=app=payments-api,version=v2,chaos=latency --timeout=90s
kubectl wait pod --for=condition=Ready --selector=app=payments-api,version=v2,chaos=exception --timeout=90s
```

Apply the traffic simulator and observe the dashboards in the Consul UI. <br>

```
kubectl apply -f observability/traffic.yml
```

Wait a few moments and observe the traffic on the Consul dashboard.

Additionally, you can deploy the Grafana dashboards below to monitor the health of the consul system, as well as your workloads.
To create the sample dashboard select the `+` in the left side navigation to `Import`. <br>

* https://grafana.com/grafana/dashboards/13396
* https://raw.githubusercontent.com/hashicorp/learn-consul-kubernetes/main/layer7-observability/grafana/hashicups-dashboard.json

In the next assignment you will look at traces for this traffic.
