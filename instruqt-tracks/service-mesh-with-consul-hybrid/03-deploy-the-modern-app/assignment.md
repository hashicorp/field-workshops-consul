---
slug: deploy-the-modern-app
type: challenge
title: Deploy the Modern App
teaser: Deploy our application on K8s.
notes:
- type: text
  contents: Now that we have our legacy service running in DC2, let's deploy the rest
    of the application in DC1.
tabs:
- title: DC2 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc2
  port: 8500
- title: DC1 - K8s
  type: terminal
  hostname: dc1-kubernetes
- title: DC1 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc1
  port: 8500
- title: DC1 - App Config
  type: code
  hostname: dc1-kubernetes
  path: /root/tracing
difficulty: basic
timelimit: 900
---
We've made a few minor changes to the deployment spec from the last track.
You'll notice we've removed the spec file for the `currency` service, as it's already running in DC2. <br>

We've also removed the `sidecar` upstreams from the `payments` service that calls the currency service, replaced it with a _Consul DNS_ definition instead. <br>

This is a common transition pattern where service discovery aware apps can become service mesh aware in a phased rollout.
You can read more about this integration in K8s [here](https://www.consul.io/docs/platform/k8s/dns.html). <br>

Check this out in the `payments.yml` deployment file. <br>

```
- name: UPSTREAM_URIS
  value: "http://currency.service.dc2.consul:9094"
```

Let's deploy the rest of the application and test it. Our frontend web component is accessible via NodePort.

```
kubectl apply -f  tracing

sleep 30

kubectl wait --for=condition=Ready $(kubectl get pod --selector=app=web -o name)
kubectl wait --for=condition=Ready $(kubectl get pod --selector=app=api -o name)
kubectl wait --for=condition=Ready $(kubectl get pod --selector=app=cache -o name)
kubectl wait --for=condition=Ready $(kubectl get pod --selector=app=payments -o name)
```

Once all the pods are ready, we can send traffic to the frontend.

```
curl -s localhost:30900 | jq
```

Hmmm, it looks like something went wrong. You should see a similar timeout message. <br>

```
rpc error: code = Internal desc = Error processing upstream request
```

That error is not particularly helpful.
Let's use our tracing infrastructure to run this down in the next assignment.