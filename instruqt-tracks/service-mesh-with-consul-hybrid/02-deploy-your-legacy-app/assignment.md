---
slug: deploy-your-legacy-app
id: tllzuoxgzfbe
type: challenge
title: Deploy your Legacy App
teaser: Deploy legacy services to your on-prem datacenter.
notes:
- type: text
  contents: |-
    We will use our tracing app from the previous track for this lab.
    As you recall, the app is broken out into five components:

    * Frontend - Access to our application
    * API - gRPC API to backend services
    * Cache - Cache responses for our API
    * Payments  - Process payments
    * Currency - Do currency lookups for our payments

    Our currency service will represent our legacy workload running on-prem in DC2.
tabs:
- title: DC2 - UI
  type: service
  hostname: dc2-consul-server
  path: /ui/dc2
  port: 8500
- title: DC2 - App
  type: terminal
  hostname: dc2-app-server
difficulty: basic
timelimit: 900
---
Let's take a quick look at Consul in this DC. <br>

```
consul members
```

We have the Currency service running for you on the VM in DC2.
You can see the app running in Docker. <br>

```
docker ps -a
```

Let's add a Consul health check for the service, and reload it.

```
cat <<-EOF > /etc/consul.d/currency-service.json
{
  "service": {
    "name": "currency",
    "tags": [
      "production"
    ],
    "port": 9094,
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

You should see a healthy service in Consul. We can also test this service locally.

```
curl -s  http://127.0.0.1:9094 | jq
```

Nice work! Now let's deploy the rest of our application in the other datacenter.