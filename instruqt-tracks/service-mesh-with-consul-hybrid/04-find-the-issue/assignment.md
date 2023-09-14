---
slug: find-the-issue
id: xeiyeagxgrqr
type: challenge
title: Find the Issue
teaser: Something is not quite right...
notes:
- type: text
  contents: |-
    In this section we will investigate the connectivity issues between
    DCs. We'll wait a few moments for our traces to propagate.
tabs:
- title: DC1 - K8s
  type: terminal
  hostname: dc1-kubernetes
- title: Jaeger UI
  type: service
  hostname: dc1-jaeger-server
  path: /search?service=web
  port: 16686
difficulty: basic
timelimit: 900
---
Let's revisit our Jaeger UI and take a look at the latest trace data.
You should see a message similar to this  in the payments trace.
You can get to this message quickly by clicking on the `expand all` button in Jaeger for the trace. <br>

```
"error:Error communicating with upstream service: Get http://currency.service.dc2.consul:9094/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)"
```

It seems even though we could discover the service in the datacenter, we don't actually have a route to that service, or the network is blocking it.

Let's explore this further with a basic connectivity check between our K8s node and our server running in the other DC.
We can use a tool called `nmap` to help us with this verification. <br>

We know that IP is our Currency service running on our DC2 app server, so we can test with the below command. <br>

```
ip=$(getent ahostsv4 dc2-app-server |  awk '{print $1}' | head -1)
nmap -p 9094 $ip
```

It looks like that route is indeed blocked. We can see the status as `filtered`. <br>

Let's look at how Mesh Gateways can help us solve this problem in the next exercise.