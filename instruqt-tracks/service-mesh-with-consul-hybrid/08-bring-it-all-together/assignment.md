---
slug: bring-it-all-together
id: z1mn5uy8ougt
type: challenge
title: Bring it all Together
teaser: You're first multi-dc mesh
notes:
- type: text
  contents: |-
    Now that we have gateways to connect our DCs, we can redeploy our application, and route the entire component flow through the sidecars and gateways.
    We'll inspect some of the traffic through the gateways to validate they are being used, and look specifically at the **SNI** headers, as well as trace data. <br>
tabs:
- title: DC2 - Gateway
  type: terminal
  hostname: dc2-consul-gateway
- title: DC1 - App Config
  type: code
  hostname: dc1-kubernetes
  path: /root/tracing/payments.yml
- title: DC1 - K8s
  type: terminal
  hostname: dc1-kubernetes
- title: DC1 - Gateway
  type: terminal
  hostname: dc1-consul-gateway
- title: Jaeger UI
  type: service
  hostname: dc1-jaeger-server
  path: /search?service=web
  port: 16686
difficulty: basic
timelimit: 900
---
First, let's set up tcpdump to inspect the traffic on our gateways. <br>

On the DC1 gateway, run the following. This filter looks specifically at the SSL handshake hello packet. <br>

```
tcpdump -i ens4 -s 1500 '(tcp[((tcp[12:1] & 0xf0) >> 2)+5:1] = 0x01) and (tcp[((tcp[12:1] & 0xf0) >> 2):1] = 0x16)' -nnXSs0 -ttt
```

On the DC2 gateway, run the following.  We'll look at all the packets.

```
tcpdump -i ens4 port 443 -nnXX -vv -A
```


You'll notice the upstream definition has an a datacenter tag appended to the upstream, for `dc2`. You can see this in the code editor.
We've set the gateways up in [local](https://www.consul.io/docs/connect/mesh_gateway.html#local) mode so this will send all cross DC traffic through our gateways. <br>

```
"consul.hashicorp.com/connect-service-upstreams": "currency:9094:dc2"
```

Now we can redeploy our app on the `DC1 - K8s` tab.

```
kubectl apply -f tracing
sleep 10
kubectl wait --for=condition=Ready $(kubectl get pod --selector=app=payments -o name)
```

Next, let's simulate some traffic through the `DC1 - K8s` tab.

```
curl -s localhost:30900 | jq
```

Awesome. You've fixed the application across DCs!! Go check out the new Jaeger traces!! <br>

If you look closely at the packets in the `DC1 - Gateway` tab you'll see a a similar value that is not encrypted.

```
currency.default.dc2.internal.<domain>.consul
```

That's the SNI header. It's the **only** piece of information the gateway can see, and this value allows it to be sent to the correct destination. <br>

The packet is not decrypted until it reaches the last sidecar proxy, so we have end-to-end encryption across over the WAN between our DCs. <br>

Nice work!!! You just ran your first Mesh Gateway workload!!!