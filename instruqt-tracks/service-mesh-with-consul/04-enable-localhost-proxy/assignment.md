---
slug: enable-localhost-proxy
type: challenge
title: "Enter the Meshtrix \U0001F469\U0001F3FB‍\U0001F4BB"
teaser: Use Consul and Envoy to connect our application to a backend database
notes:
- type: text
  contents: In this section will use Envoy to connect the application to the database.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: App
  type: terminal
  hostname: app
- title: App Config
  type: code
  hostname: app
  path: /var/www/html/wp-config.php
- title: Website
  type: service
  hostname: app
  port: 80
difficulty: basic
timelimit: 900
---
In the last assignment we created an Envoy listener for our database
service through a Connect upstream definition. <br>

Let's use that definition to allow our application to connect to the database. <br>

On line 32 of the `App Config` tab, recall our listener is configured on localhost, so we can just update our address to `127.0.0.1`, and establish connectivity. <br>

Go ahead and do this now. Check the `Website` tab.
Our service mesh blog is back online!