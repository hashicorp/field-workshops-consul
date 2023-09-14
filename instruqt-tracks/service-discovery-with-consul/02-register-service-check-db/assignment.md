---
slug: register-service-check-db
id: qy8zgg6pz8mv
type: challenge
title: Register a Service Check for the Database ✔️
teaser: In this challenge you'll attach a health check to the database service so
  we can monitor its status.
notes:
- type: text
  contents: |-
    Now that you've got the website back up and running, it's time to put a health check on that database service. <br>

    Application health checks are easy to build and can check a wide array of conditions.
    Once you have this rich data it is easy to build automation around it. <br>

    In this challenge you'll configure a service health check on the database server,
    so that you'll always know where the database service is, and whether it is healthy.
- type: video
  url: https://www.youtube.com/embed/CIv65T172mU?modestbranding=1&rel=0
- type: text
  contents: "✔️ Check Yourself Before you Wreck Yourself \U0001F468‍\U0001F4BB"
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: Database Server
  type: terminal
  hostname: database
difficulty: basic
timelimit: 900
---
In this challenge you'll create a service check that will register the database service in Consul's catalog. You'll need to copy a service definition file into the Consul config directory to activate the service.

Click on the database server tab and use the `cat` command to have a look inside the service definition file:
```
cat /database_service.json
```

The config file contains a service check named mysql with a health check that monitors port 3306. If the database ever goes down Consul can immediately mark it as unhealthy. Consul can automatically route traffic to healthy nodes.

Next copy the file into the Consul config directory:
```
cp /database_service.json /consul/config/database_service.json
```

Then go ahead and reload the Consul service:

```
consul reload
```

Look at the services tab in the Consul UI. You should now see a service name and health check for your database.

To find the health check in the UI click on *Services* and then *mysql*.

NOTE: It may take a moment for the health check to show up as healthy.
