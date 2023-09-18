---
slug: the-website-is-down
type: challenge
title: "The website is DOWN! \U0001F631"
teaser: |
  The company website is down and it's up to you to fix it. Use your Consul superpowers to find the database server and reconnect it to the app.
notes:
- type: text
  contents: |
    Consul has a complete and up-to-date map of all the hosts in your network.

    Gone are the days of cumbersome, error-prone spreadsheets and Configuration Management Database (CMDB) systems.

    The current IP address of each host is easy to find in the Consul UI.

    Visit the *Nodes* tab of the Consul UI to see the IP addresses of all your machines.
- type: text
  contents: "\U0001F441️ Next Stop...the Consul Zone \U0001F570️"
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  path: /ui/dc1/nodes/Database
  port: 8500
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
The website is DOWN! Your application server is not working correctly. You've determined that the app can't connect to the database.

Click on the *Nodes* tab in the Consul UI to find the database server's IP address.

Edit the `wp-config.php` file in the *App Config* tab. On line 32 you'll find the configuration for the database server. Update the IP address in the file and save it with *CTRL-S*.

Verify that the application is loading in the *Website* tab. You may need to hit the refresh button for the site to load.
