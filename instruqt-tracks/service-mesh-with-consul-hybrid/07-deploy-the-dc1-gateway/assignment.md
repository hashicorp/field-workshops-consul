---
slug: deploy-the-dc1-gateway
id: ilvgq6nayfv6
type: challenge
title: Deploy the DC1 Gateway
teaser: Establish gateway connectivity across datacenters
notes:
- type: text
  contents: Now that we have a Gateway in DC2 that can talk to our legacy service,
    we can spin up a gateway in DC1, and connect the two gateways.
tabs:
- title: DC1 - Gateway
  type: terminal
  hostname: dc1-consul-gateway
- title: DC1 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc1
  port: 8500
- title: DC2 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc2
  port: 8500
difficulty: basic
timelimit: 900
---
First, let's check our connectivity again.
We can check this between gateways now that our DC2 gateway is accepting traffic. <br>

Let's check the gateway to the DC2 app server first.

```
ip=$(getent ahostsv4 dc2-app-server |  awk '{print $1}' | head -1)
nmap -p 9094 $ip
```

Let's check the gateway in DC1 to the gateway in DC2.

```
ip=$(getent ahostsv4 dc2-consul-gateway |  awk '{print $1}' | head -1)
nmap -p 443 $ip
```

Our gateway can reach the other gateway, but not the app server.
This is the behavior we expect based on our lab environment.
The gateways will handle all the cross DC traffic, so we don't have to worry about it. <br>

Now let's start up the Gateway in DC1.
There is a preconfigured Consul agent on this box. <br>

```
local_ipv4=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
nohup consul connect envoy -mesh-gateway -register \
                 -service "gateway" \
                 -address ${local_ipv4}:443 \
                 -wan-address ${local_ipv4}:443 \
                 -bind-address "public=${local_ipv4}:443" \
                 -admin-bind 127.0.0.1:19000 > /gateway.out &
```

We can now verify our new listener.

```
curl localhost:19000/listeners
```

Now that we have gateway to gateway connectivity, let's fix our app and redeploy it to use the sidecars across gateways.