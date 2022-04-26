---
slug: observability-tracing
id: rmuxawbcexxc
type: challenge
title: 'Observability: Tracing'
teaser: Inspect trace information
tabs:
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
- title: Jaeger UI
  type: service
  hostname: k8s1
  path: /
  port: 16686
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
In this assignment you will look at application traces across your APIs.
You can see the application traces from the load generation.  <br>

Observe the trace data in Jaeger. Notice the long running traces, as well as the traces with exceptions.
