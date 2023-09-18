---
slug: connect-your-datacenters
type: challenge
title: Connect your Datacenters
teaser: Connect two DCs across a WAN network.
notes:
- type: text
  contents: |-
    In this track we will connect applications across two separate datacenters, with application components in each.
    Our lab datacenters will reflect a common heterogeneous environment.

    * DC1 - Kubernetes & VM Environment (greenfield)
    * DC2 - VM Environment (legacy)

    The two most common problems when connecting datacenters in this pattern are:

    1. Overlapping IP spaces
    2. Firewall complexities

    In this track we will show you how Consul Connect and Mesh Gateways can solve this problem. <br>

    We need a few minutes to spin up your K8s infrastructure.
tabs:
- title: DC1 - Consul
  type: terminal
  hostname: dc1-consul-server
- title: DC1 - UI
  type: service
  hostname: dc1-consul-server
  path: /ui/dc1/nodes
  port: 8500
- title: DC2 - UI
  type: service
  hostname: dc2-consul-server
  path: /ui/dc2/nodes
  port: 8500
difficulty: basic
timelimit: 900
---
Let's take a brief moment to review our environment. <br>

In DC1, we have a VM running a Consul server.
We also have a Kubernetes cluster running with a single worker node.
This Kubernetes worker node has a Consul agent running on it with a DaemonSet. <br>

We can see this below. <br>

```
consul members
```

In DC2, we have a VM running a Consul server.
We also have a VM that will run our legacy service.
We'll inspect this Consul cluster in the next section. <br>

The lab is preconfigured for connectivity within each Consul DC, but we need to make each datacenter Consul aware of the other datacenter. <br>

Let's do this by connecting our two Consul datacenters with a `wan join`.
This will allow us to manage our workloads across the datacenters. <br>

**Note**: the lab env helps us this with this resolution of short names for our lab servers.  <br>

```
consul join -wan dc2-consul-server
```

Now let's check our members output

```
consul members -wan
```

Great! Now that we have federation between our Consul datacenters, we can start deploying our workloads.