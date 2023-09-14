---
slug: seamless-service-discovery
id: icwdlsw0pseb
type: challenge
title: "Seamless Service Discovery with Consul DNS \U0001F5A7"
teaser: Consul can provide seamless access to all nodes and services in the catalog,
  without rewriting your apps.
notes:
- type: text
  contents: |
    The Consul catalog can seamlessly integrate with your current application infrastructure without changing any of your code.
    Imagine giving all your applications and services easy access to configuration data, health checks, and network info. <br>

    This is the magic of Consul DNS integration. With this configuration any application that speaks DNS can take advantage of the powerful Consul service catalog.
    In the next challenge we'll use dnsmasq to route all local queries for *.consul addresses to the Consul service. Our application will now be able to use a simple Consul-managed DNS name for connecting to the database.
- type: text
  contents: |-
    There are several different ways to integrate Consul into your system DNS. <br>
    Check out the HashiCorp Learn guide to learn more about DNS forwarding: https://learn.hashicorp.com/consul/security-networking/forwarding
- type: text
  contents: "\U0001F310 Consul - A Powerful DNS-based Service Catalog \U0001F578️"
tabs:
- title: Website
  type: service
  hostname: app
  port: 80
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: App Config
  type: code
  hostname: app
  path: /var/www/html/wp-config.php
- title: App Server
  type: terminal
  hostname: app
difficulty: basic
timelimit: 900
---
In this exercise you'll configure Consul to act as a local DNS server,
providing seamless access to your service catalog via simple DNS hostnames. The
Linux dnsmasq service is running on your application server. <br>

Run the following command to see the dnsmasq configuration: <br>

```
cat /etc/dnsmasq.d/consul
```

The server config lines say _Direct all traffic for .consul queries to Consul on local port 8600, everything else to our normal DNS server_. <br>

Now look at the `/etc/resolv.conf` file.
This is the file that controls where DNS queries are routed. <br>

```
cat /etc/resolv.conf
```

We are now routing all DNS queries through our local system, but only *.consul queries are handled by Consul.
All other DNS traffic is passed upstream to the corporate DNS server.
Try it yourself with the `dig` command: <br>

```
dig mysql.service.consul
```

Edit line 32 of the `wp-config.php` file again, but this time instead of using an IP address
use the Consul DNS name for your database server node: <br>

```
mysql.service.consul
```

Visit the Website tab and verify that the app has connected to the database using Consul DNS.
