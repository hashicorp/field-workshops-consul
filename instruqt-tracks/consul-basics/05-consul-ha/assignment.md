---
slug: 05-consul-ha
id: twklmkkkdxlb
type: challenge
title: Consul High Availability
teaser: Test Consul's High Availability Capabilities
notes:
- type: text
  contents: |-
    Consul servers work together to elect a single leader, which becomes the primary source of truth for the cluster. All updates are forwarded to the cluster leader. If the leader goes down one of the other servers can immediately take its place.

    To ensure high availability within the system, we recommend deploying Consul with 3 or 5 server nodes.
- type: text
  contents: |-
    Quorum requires at least (n+1)/2 members. You need quorum for a healthy cluster. <br>

    A three-node cluster can tolerate the loss of a single member.
    A five-node cluster can tolerate the loss of two members and continue to operate.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: Consul0
  type: terminal
  hostname: consul-server-0
- title: Consul1
  type: terminal
  hostname: consul-server-1
- title: Consul2
  type: terminal
  hostname: consul-server-2
- title: App
  type: terminal
  hostname: consul-agent-0
difficulty: basic
timelimit: 600
---
We have 3 servers in our lab environment. This means we can lose one
server and still have a healthy cluster. You can read more about the Consensus
Protocol [here](https://www.consul.io/docs/internals/consensus.html). <br>

Let's disable the leader and observe what happens. <br>

First, find your current leader.
You can  do this from the UI (look for the star), or on the command line: <br>

```
consul operator raft list-peers
```

Go to the tab of your current leader and run the following command to stop the Consul agent: <br>

```
pkill consul
```

If your leader happens to be `Consul0` you will temporarily lose access to the UI. <br>

Repeat the above process on the leading server terminal tab, and kill the new leader. <br>

Run the following commands on the last server: <br>

```
consul members
consul operator raft list-peers
consul catalog nodes
```

You'll see error messages like this: `Unexpected response code: 500 (No cluster leader)` <br>

Now that two servers have failed your cluster is no longer functional,
all API commands will result in errors until at least one of your other servers comes back online.
Let's recover by starting Consul back up. Run the following command on one of the failed nodes: <br>

```
/bin/start_consul.sh
```

Now run `consul members` to verify that the Consul API is responding again. <br>

Bring back your third server with the startup script: <br>

```
/bin/start_consul.sh
```

And run `consul members` one last time. You should see all three server nodes in alive status. <br>

Congratulations, your Consul cluster is healthy again.