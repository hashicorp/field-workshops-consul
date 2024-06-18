---
slug: sidecar-envoy
type: challenge
title: Pop Open the Hood ⚙️
teaser: Peek inside and learn some Envoy & Consul magic
notes:
- type: text
  contents: |-
    In this assignment, we'll take a deeper look at Envoy. We'll focus on three elements that make up the foundation of our mesh. <br>

    * mTLS - How did Connect and Envoy provide end-to-end encryption between services?
    * Service Discovery - How was Consul able to get service discovery information to the Envoy proxy for it's upstreams?
    * Intentions - How were we able to allow or deny traffic based on service identity?

    Let's investigate each of these with some easy to get info from Envoy.
tabs:
- title: App - Envoy
  type: service
  hostname: app
  port: 19000
- title: App - Cert
  type: code
  hostname: app
  path: /tmp/crt.txt
- title: App - Authorize
  type: code
  hostname: app
  path: /tmp/payload.json
- title: App
  type: terminal
  hostname: app
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: Website
  type: service
  hostname: app
  port: 80
difficulty: basic
timelimit: 900
---
First, let's check out some of the certificate information from our Envoy proxy.
You can see some basic cert info in the Envoy UI under `certs`.
We've also grabbed the cert for you and decoded in the code editor. <br>

We can look some basic certificate information from Envoy with the below command.
```
curl -s localhost:19000/certs | jq '.certificates[0].cert_chain[0].subject_alt_names[0].uri'
```
Nice! That's the identity for our application in the mesh. We can see the TTL for the certificate

Let's see when that  cert expires.
```
curl -s localhost:19000/certs | jq '.certificates[0].cert_chain[0].days_until_expiration'
```
Our certificate TTL is very short, 2 days! And as a bonus, it's automatically managed by Consul. <br>

Second, let's check out some of the service discovery information from our Envoy proxy. You can see the this in the Envoy UI under `clusters`.

```
curl -s localhost:19000/clusters | grep  mysql
```

We can see the `added_via_api::true` is set for our `database` cluster, which means the Consul agent sent this to Envoy via the API.
We can also validate that the ip address in Envoy matches the ip address in Consul for the database node.

```
curl -s  http://127.0.0.1:8500/v1/catalog/node/Database | jq '.Node.Address'
```

Last, we can do some basic intention validation by emulating the API call made from Envoy to  the Consul agent.

```
curl -s -X POST -d @/tmp/payload.json http://127.0.0.1:8500/v1/agent/connect/authorize |  jq
```

That's it!!! Now you're an expert at troubleshooting Connect & Envoy!!!