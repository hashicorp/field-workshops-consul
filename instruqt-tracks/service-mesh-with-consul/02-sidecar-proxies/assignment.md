---
slug: sidecar-proxies
type: challenge
title: "Introducing the Envoy Proxy \U0001F5A7"
teaser: Run your first Connect sidecar proxy with Envoy
notes:
- type: text
  contents: |-
    In the last challenge we set up a sidecar service definition for our
    Envoy proxy. This is the first step in bringing our mesh to life. <br>

    The sidecar definition tells Consul to expect a proxy registration for a service, Database, in this example. <br>

    Now that Consul is aware that the Database service should run a proxy,
    we can use the Consul agent to bootstrap the proxy and send it dynamic configuration. <br>

    We'll take a deeper look at this configuration later.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: Database
  type: terminal
  hostname: database
- title: Database Service
  type: code
  hostname: database
  path: /etc/consul.d/database_service.json
difficulty: basic
timelimit: 900
---
Now that we've registered a proxy service in Consul for our MySQL database,
let's start the proxy server so the health check will pass. <br>

Consul will bootstrap the proxy with the correct configuration, and bring it into the mesh for us. <br>

We've placed an Envoy binary on this machine for you.
Consul will be able to access it from the `$PATH.` <br>

Go ahead and start the proxy with the following command: <br>

```
nohup consul connect envoy -sidecar-for mysql > /envoy.out &
```

You can verify in the Consul UI or the with the Consul CLI that your proxy health check is now passing. <br>

We can now use the proxy to establish communication between our application and the database!