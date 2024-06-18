---
slug: sidecar-services
type: challenge
title: "Get Into My Sidecar \U0001F697"
teaser: Create a sidecar service definition for your application proxy
notes:
- type: text
  contents: |-
    Connect proxies are typically deployed as _sidecars_ to an instance
    that they handle traffic for. They might be on the same bare metal server, virtual
    machine, or Kubernetes daemonset. Connect has a pluggable proxy architecture,
    with awesome first-class support for Envoy. We'll use Envoy as our proxy for
    the entirety of this workshop. <br>

    Visit the [Connect docs](https://www.consul.io/docs/connect/proxies.html) for more info on proxy integration. <br>

    In this challenge, we'll set up a sidecar definition.
- type: image
  url: https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/docs/slides/multi-cloud/consul-oss/images/connect_sidecar.png
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
In this challenge we'll add a sidecar service to our existing service definition. <br>

The `sidecar_service` field is a nested service definition where almost any regular service definition field can be set. <br>

All fields in the nested definition are optional, however there are some default settings
that make sidecar proxy configuration much simpler. <br>

In orchestrated environments,such as `Kubernetes` or `Nomad`, this is highly abstract and can be configured
with simple metadata i.e. annotations. <br>

Update the definition by adding the the `connect` block as seen below.
Copy and paste what's below over the entire file in the *Database Service* tab.
Use CTRL-S to save the file. <br>

```
{
  "service": {
    "name": "mysql",
    "tags": [
      "database",
      "production"
    ],
    "port": 3306,
    "connect": { "sidecar_service": {} },
    "check": {
      "id": "mysql",
      "name": "MySQL TCP on port 3306",
      "tcp": "localhost:3306",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
```

Next, reload Consul: <br>

```
consul reload
```

You should see a failing service called `mysql-sidecar-proxy` in Consul.
This is expected! <br>

We will start a proxy and register it with Connect in our next challenge.