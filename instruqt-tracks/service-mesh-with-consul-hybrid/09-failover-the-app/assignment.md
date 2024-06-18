---
slug: failover-the-app
type: challenge
title: Test a Failover
teaser: Migrate a legacy app with DC failover
notes:
- type: text
  contents: |-
    Let's revisit the last few assignments with a common deployment scenario and simulate a failover. <br>

    The legacy service is undergoing a migration to the new DC, DC1.
    The application will continue to run in the old DC, DC2, during this transition.
    In the event the newly migrated application fails, traffic will seamlessly route back to DC2. <br>
tabs:
- title: DC1 - K8s
  type: terminal
  hostname: dc1-kubernetes
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
- title: Jaeger UI
  type: service
  hostname: dc1-jaeger-server
  path: /search?service=web
  port: 16686
- title: DC1 - Gateway
  type: terminal
  hostname: dc1-consul-gateway
- title: DC2 - Gateway
  type: terminal
  hostname: dc2-consul-gateway
- title: DC2 - App
  type: terminal
  hostname: dc2-app-server
- title: DC1 - App Config
  type: code
  hostname: dc1-kubernetes
  path: /root/tracing
difficulty: basic
timelimit: 300
---
Remember, these gateways operate by sniffing the [SNI header](https://en.wikipedia.org/wiki/Server_Name_Indication) out of the Connect session,
and then routing the connection to the appropriate destination based on the server name requested.
The mesh gateways we deployed in the previous assignments will handle the WAN traversal.
You will introspect SNI values throughout the failover workflow. <br>

First, deploy all application components to the new DC, DC1.

```
kubectl apply -f tracing
```

Now, verify you have the currency service running in both DCs.
You can check the in the UI or use the API.

```
curl -s 'http://127.0.0.1:8500/v1/health/service/currency?passing=true&dc=dc1' | jq
curl -s 'http://127.0.0.1:8500/v1/health/service/currency?passing=true&dc=dc2' | jq
```

Now that you have healthy services in both DCs you can create a failover config.

```
cat <<EOF | consul config write -
kind            = "service-resolver"
name            = "currency"
connect_timeout = "3s"
failover = {
  "*" = {
    datacenters = ["dc2"]
  }
}
EOF
consul config read -kind service-resolver -name currency
```

Consul keeps track of the health of these services in both DCs.
If the service is not available in the local DC, the data plane will update in real time, and route to the other DC.
Let's explore this further.  <br>


The payment service has the currency service in its upstream configuration.
Notice there is no explicit datacenter definition specified in the K8s deployment file.
The [central config](https://www.consul.io/docs/agent/config_entries.html) you added earlier will handle this transparently for the developer. <br>

```
cat tracing/payments.yml  | grep "consul.hashicorp.com/connect-service-upstreams"
```

Let's inspect the data plane while our currency container is healthy in DC1.
You will also compare the IP with Consul's registry.
The cluster IP address will match the POD IP value in the catalog.
The SNI value will be for DC1. <br>

```
curl -s localhost:8500/v1/catalog/service/currency?dc=dc1 | jq '[.. |."ServiceAddress"? | select(. != null)]'
kubectl exec $(kubectl get pod --selector=app=payments -o name) -c consul-connect-envoy-sidecar -- wget -qO- localhost:19000/clusters
kubectl exec $(kubectl get pod --selector=app=payments -o name) -c consul-connect-envoy-sidecar -- wget -qO- localhost:19000/config_dump | jq '[.. |."dynamic_active_clusters"? | select(. != null)[0]]'
```

When you're done comparing the values, send some traffic to the frontend service,
and inspect the Jaeger traces. Look for the `process IP` in the trace for the currency service. <br>

```
curl -s localhost:30900 | jq
```

Now you can simulate a failure by stopping the deployment in DC1.

```
kubectl delete -f tracing/currency.yml
```

The gateway is running in [local mode](https://www.consul.io/docs/connect/mesh_gateway.html#local), so the value in the data plane will update to the gateway server in the local DC.
The SNI value for that Envoy cluster has also changed. It will now point to `dc2`.
The mesh gateway will use this value to send traffic to the correct destination DC.
You can validate each of these below.

```
curl -s localhost:8500/v1/catalog/service/gateway?dc=dc1 | jq '[.. |."ServiceAddress"? | select(. != null)]'
kubectl exec $(kubectl get pod --selector=app=payments -o name) -c consul-connect-envoy-sidecar -- wget -qO- localhost:19000/clusters
kubectl exec $(kubectl get pod --selector=app=payments -o name) -c consul-connect-envoy-sidecar -- wget -qO- localhost:19000/config_dump | jq '[.. |."dynamic_active_clusters"? | select(. != null)[0]]'
```

Optionally, you can look at the packets flowing through the mesh gateways.
Run the below command on the two gateway tabs:
  * DC1 - Gateway
  * DC2 - Gateway

```
tcpdump -i ens4 port 443 -nnXX -vv -A
```

Now, send some traffic to the frontend service,
and inspect the Jaeger traces. Look for the `process IP` in the trace for the currency service.

```
curl -s localhost:30900 | jq
```

Nice work!! You just did your first application failover with Consul.