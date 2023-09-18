---
slug: automate-your-job
type: challenge
title: "Automate Your Job with Consul Template\U0001F916"
teaser: Now that you have the website back up and running, it's time to automate this
  so you don't get woken up at 2 am again.
notes:
- type: text
  contents: |
    The database and application are both registered in the Consul catalog. The health status and IP addresses of each service are always up to date, and can be queried at any time.

    In the next challenge you'll automate the configuration of your wp-config.php file using Consul Template.

    Consul Template is a small agent that can manage files and populate them with data from the Consul catalog.
- type: text
  contents: "\U0001F5A7 All Your Service Are Belong To Us \U0001F469‍\U0001F4BB"
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
- title: Consul Template
  type: code
  hostname: app
  path: /var/www/html/wp-config.php.tpl
- title: App Server
  type: terminal
  hostname: app
difficulty: basic
timelimit: 900
---
In this challenge you'll use consul-template to ensure that the application config always has the correct IP address. Run the following command on the *App Server* terminal tab to query the Consul service catalog for your database server:

```
dig @localhost -p 8600 mysql.service.consul
```

In the output you'll see a line called `ANSWER SECTION`. Right below it is the current IP address of your database server. Consul template can automatically insert this IP address into your application config file.

Click on the *Consul Template* tab and look inside the file. Consul template can update your `wp-config.php` file whenever the database IP address changes. Notice the template configuration for DB_HOST on line 32 of the file. This part is automatically replaced with the address of your healthy database server.

Run the following commands on in the *App Server* terminal to activate Consul Template.
You will run Consul Template in `once` mode for this example. In production this is typically a daemon. <br>

```
cd /var/www/html
consul-template -once -log-level debug -template "wp-config.php.tpl:wp-config.php"
```

Reload the `wp-config.php` file in your *App Config* tab to see the updated IP address.

Open the *Website* tab and verify that the web app is loading correctly.

Consul Template will continuously watch for changes and update your configuration files automatically.
