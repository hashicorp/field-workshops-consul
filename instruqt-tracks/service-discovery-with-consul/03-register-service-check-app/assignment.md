---
slug: register-service-check-app
id: rxiqqury4hcw
type: challenge
title: Register a Service Check for the Application ✔️
teaser: In this challenge you'll attach a health check to the application so we can
  monitor its status.
notes:
- type: text
  contents: You can use Consul to monitor all kinds of services. In this challenge
    you'll add a service check to your application.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: Application Server
  type: terminal
  hostname: app
difficulty: basic
timelimit: 900
---
Just like in the previous challenge, you'll need to copy a service definition file and reload Consul.

Click on the application server tab and use the `cat` command to have a look inside the service definition file:
```
cat /app_service.json
```

The config file contains a service check named http with a health check that monitors port 80. If the app ever goes down Consul can immediately mark it as unhealthy. Consul can automatically route traffic to healthy nodes.

Next copy the file into the Consul config directory:
```
cp /app_service.json /consul/config/app_service.json
```

Then go ahead and reload the Consul service:

```
consul reload
```

Look at the services tab in the Consul UI. You should now see a service name and health check for your application.

To find the health check in the UI click on *Services* and then *http*.

NOTE: It may take a moment for the health check to show up as healthy.
