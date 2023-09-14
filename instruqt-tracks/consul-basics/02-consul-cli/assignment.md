---
slug: 02-consul-cli
id: ur5wsyiizlac
type: challenge
title: Consul CLI
teaser: Take the Consul CLI for a spin
notes:
- type: text
  contents: |-
    Consul is distributed as a single binary file, which means it can act as both a server or a command line client.
    You can read more about the full list of commands [here](https://www.consul.io/docs/commands/index.html).
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
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
difficulty: basic
timelimit: 600
---
The Consul binary can act as a server, client, or command line tool. We've preconfigured the command line settings for you with the `CONSUL_HTTP_ADDR` environment variable.

You can run the following command to see this value: `echo $CONSUL_HTTP_ADDR`. This is the API server endpoint for Consul. The Consul command line tool is communicating to the API on 127.0.0.1 or localhost.

All interactions with Consul, whether through the GUI, or command line always have an underlying API call.

Try these commands and view the results. You may run the commands on any server: <br>

* Get Help:
  - `consul help` or `consul subcommand -help`
* View Logs:
  - `consul monitor` (CTRL-C to escape)
* List Members:
  - `consul members`
* List Peers:
  - `consul operator raft list-peers`
* Agent Info:
  - `consul info` <br>

You can check out the same info in the Consul UI.