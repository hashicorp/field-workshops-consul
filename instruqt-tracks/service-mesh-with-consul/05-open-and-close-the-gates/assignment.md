---
slug: open-and-close-the-gates
type: challenge
title: "Open and Close the Gates \U0001F511\U0001F6AA"
teaser: Use Consul intentions to allow or deny proxy traffic based on application
  service identity.
notes:
- type: text
  contents: Intentions define access control for services via Consul Connect and are
    used to control which services may establish connections. You can manage Intentions
    via the API, CLI, or UI. Intentions are enforced by the proxy on inbound connections.
- type: text
  contents: |-
    After verifying the TLS client certificate,
    the authorize API endpoint is called which verifies the connection.
    If authorize returns false the connection must be terminated. <br>

    Intentions are powerful because they free you from having to manage endless lists of IP address and port mappings.
    Instead, we can manage traffic in simple terms by what an application is or does. <br>

    Let's use intentions to restrict connectivity from our application to the database.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: app
  type: terminal
  hostname: app
- title: Website
  type: service
  hostname: app
  port: 80
difficulty: basic
timelimit: 900
---
Traffic is denied by default at the start of this assignment, so our application is now broken. <br>
Let's create an allow rule to bring back our application.
Copy the following command into the *app* tab. <br>

```
consul intention create -allow wordpress mysql
```

You can also manage Intentions in the `Intentions` tab of the Consul UI.
Click on the intention, and change it to `deny`.  What happens? <br>

Change it back to `allow` to restore service.
With connectivity from the database restored, your application should be serving traffic once again!!! <br>

We'll dive deeper into how this works in the next challenge.