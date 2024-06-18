---
slug: sidecar-upstreams
id: lnuchprfqt2m
type: challenge
title: "Connect Upstream with Envoy \U0001F517"
teaser: Add an upstream definition for our Envoy app proxy
notes:
- type: text
  contents: |-
    Connect provides service connectivity through upstream definitions.
    These services could be a database, backend, or any service which another service relies on. <br>

    In the previous challenges we set up a sidecar service definition without an upstream definition.  <br>

    In this assignment we'll modify our sidecar service and add an upstream definition that will allow our application to connect to its database.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: App
  type: terminal
  hostname: app
- title: App Service
  type: code
  hostname: app
  path: /etc/consul.d/application_service.json
difficulty: basic
timelimit: 900
---
We've brought back our application server for this assignment. <br>

It has an empty sidecar_service definition, which you can see in the code editor.
Let's modify it below to create connectivity to our database. <br>

Modify the application's `sidecar_service` definition to add our upstream for the database.
You can copy and paste the entire file from below: <br>

```
{
  "service": {
    "name": "wordpress",
    "tags": [
      "wordpress",
      "production"
    ],
    "port": 80,
    "connect": {
      "sidecar_service": {
        "proxy": {
          "upstreams": [
            {
              "destination_name": "mysql",
              "local_bind_port": 3306
            }
          ]
        }
      }
    },
    "check": {
      "id": "wordpress",
      "name": "wordpress TCP on port 80",
      "tcp": "localhost:80",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
```

Next, reload Consul.

```
consul reload
```

Envoy will create a loopback listener for us to connect to the database on port `3306`. <br>

Envoy has an admin interface that listens on port `19000` by default.
We can check out our new listener with following command: <br>

```
curl localhost:19000/listeners
```

We'll configure our application to use the listener in our next assignment.