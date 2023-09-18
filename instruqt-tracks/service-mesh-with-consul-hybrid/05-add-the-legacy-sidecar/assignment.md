---
slug: add-the-legacy-sidecar
type: challenge
title: Add the Legacy Sidecar
teaser: Bring our legacy service into the mesh
notes:
- type: text
  contents: To make our legacy service work with the mesh gateways, we need to run
    a proxy next to the service, which we will deploy in this assignment.
tabs:
- title: DC2 - App
  type: terminal
  hostname: dc2-app-server
- title: DC2 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc2
  port: 8500
difficulty: basic
timelimit: 900
---
Let's start by updating consul with a sidecar service definition. <br>

```
cat <<-EOF > /etc/consul.d/currency-service.json
{
  "service": {
    "name": "currency",
    "tags": [
      "production"
    ],
    "port": 9094,
    "connect": { "sidecar_service": {} },
    "check": {
      "id": "http",
      "name": "traffic on port 9094",
      "http": "http://127.0.0.1:9094/health",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
EOF

consul reload
```

Now we can start our sidecar.

```
nohup consul connect envoy -sidecar-for=currency > /envoy.out &
```

Excellent. Now let's create our gateways.