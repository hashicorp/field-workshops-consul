---
slug: 06-consul-acls
id: qlfdatwayytc
type: challenge
title: Consul ACLs
teaser: Set up basic Consul ACLs
notes:
- type: text
  contents: |-
    Consul uses Access Control Lists (ACLs) to secure the UI, API, CLI, service communications, and agent communications.
    ACLs operate by grouping rules into policies, then associating one or more policies with a token.
    ACLs are imperative for all Consul production environments. <br>

    For a detailed explanation of the ACL system, check out this [guide](https://learn.hashicorp.com/consul/security-networking/production-acls). <br>

    This challenge will take 1-2 minutes to spin up. Please be patient.
tabs:
- title: Consul UI
  type: service
  hostname: consul-server-0
  port: 8500
- title: App
  type: terminal
  hostname: consul-agent-0
- title: App Node Policy
  type: code
  hostname: consul-server-2
  path: /consul/policies/app.hcl
- title: ACL Bootstrap
  type: code
  hostname: consul-server-2
  path: /tmp/bootstrap.txt
difficulty: basic
timelimit: 600
---
Let's apply some access controls to our Consul cluster to prevent unauthorized access. In this challenge you'll use the master bootstrap token to access the UI and to enable a policy for your app server.

You may notice that you're locked out of the UI. None of the nodes and services are showing up because of a default *deny* policy.

Consul ACLs are enabled by running the `consul acl bootstrap` command.

We've already run this command for you and saved the output in the `ACL Bootstrap` code editor tab. The initial bootstrap token is the `SecretID` field of this output. This special token is used to configure your cluster and to generate other tokens. Copy the bootstrap token by highlighting it and pressing CTRL-C. <br>

To re-enable the UI, select the Consul UI tab, and click on the ACL tab and enter your token into the text field.

On the command line you should set an environment variable with your token. Run the following command on the `App` tab:

```
export CONSUL_HTTP_TOKEN=<your_token_here>
```

This lab has a deny by default policy, so your `App` node will be logging ACL errors. Run the following command to view the ACL errors (CTRL-C to exit):

```
consul monitor
```

```
2019/09/18 20:42:06 [WARN] agent: Coordinate update blocked by ACLs
```

The app server is currently blocked from making any consul updates or queries.

Let's create a policy to enable limited access for our app node. Run these commands from the `App` tab.

```
consul acl policy create \
 -name app \
 -rules @/consul/policies/app.hcl
```

Next, create a token for that policy.

```
consul acl token create -description "app agent token" \
  -policy-name app
```

Finally apply the token to make it active.

```
consul acl set-agent-token agent "<your_app_agent_token>"
```

You can now verify that the `App` agent logs are no longer logging errors.
Nice work!!! You just secured your first Consul agent!