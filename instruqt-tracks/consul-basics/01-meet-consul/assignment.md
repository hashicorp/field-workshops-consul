---
slug: 01-meet-consul
type: challenge
title: Get to Know Consul
teaser: My First Consul cluster
notes:
- type: text
  contents: "\U0001F578️You are about to enter the Consul Zone\U0001F47D"
tabs:
- title: Consul0
  type: terminal
  hostname: consul-server-0
- title: Consul1
  type: terminal
  hostname: consul-server-1
- title: Consul2
  type: terminal
  hostname: consul-server-2
- title: Server0 - Config
  type: code
  hostname: consul-server-0
  path: /consul/config/server.json
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
difficulty: basic
timelimit: 600
---
Welcome to Consul Basics! In this lab you'll start up a three-node Consul cluster.

Once all three nodes have joined the server cluster you should see the Consul UI become healthy.

Start the Consul server process on each cluster node with the following command.

```
/bin/start_consul.sh
```

You can simply copy and paste it into the terminal for each server. You may also view the config for one of the Consul servers in the code editor. You don't need to understand all the options, just notice that we are starting Consul in `server` mode. (This is on line 8 in the config file.)

Try reloading the UI after starting each server.

Our startup script is simple and runs Consul as a background process. In production this would be daemonized or managed by an orchestrator.

Once you have a healthy cluster, the Consul UI will become available. Click on the Nodes tab in the Consul UI to see your three servers. The leader is marked with a star. ⭐
