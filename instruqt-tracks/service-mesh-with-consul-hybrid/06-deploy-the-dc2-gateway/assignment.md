---
slug: deploy-the-dc2-gateway
type: challenge
title: Deploy the DC2 Gateway
teaser: Connect our Gateway to our legacy app
notes:
- type: text
  contents: |-
    In the last assignment we discovered our Kubernetes cluster in DC1 was not able to route to our legacy app running in DC2.
    This is a common problem, and in general these types of routes can be tricky to set up and secure. <br>

    In this lab we will deploy a Mesh Gateway in DC2 and establish connectivity between the gateway and our service.
tabs:
- title: DC2 - Gateway
  type: terminal
  hostname: dc2-consul-gateway
- title: DC2 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc2
  port: 8500
difficulty: basic
timelimit: 900
---
We have introduced a new server that will represent ingress and egress points for DC2.
Let's do some basic connectivity checks before we make Consul aware of our gateway nodes. <br>

Let's first check our gateway in DC2 can reach the local app.
We'll use some helpful resolution from the lab env to grab the same IP from our Jaeger trace. <br>

```
ip=$(getent ahostsv4 dc2-app-server |  awk '{print $1}' | head -1)
nmap -p 9094 $ip
```

It looks like our Gateway server in DC2 has a direct route to our application.
We can see this with the state of `open`. Progress!

Now we can configure the node to be a mesh gateway and bring it into our mesh.
There is a Consul agent already running on this machine. <br>

```
local_ipv4=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
nohup consul connect envoy -mesh-gateway -register \
                 -service "gateway" \
                 -address ${local_ipv4}:443 \
                 -wan-address ${local_ipv4}:443 \
                 -bind-address "public=${local_ipv4}:443" \
                 -admin-bind 127.0.0.1:19000 > /gateway.out &
```
Now we've got our gateway running we can see we have a listener for this traffic.

```
curl localhost:19000/listeners
```

Let's repeat this deployment in DC1.