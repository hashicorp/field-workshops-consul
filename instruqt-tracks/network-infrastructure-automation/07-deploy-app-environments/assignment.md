---
slug: deploy-app-environments
type: challenge
title: Deploy App environments
teaser: Deploy a 2-tier VM based application to the cloud.
notes:
- type: text
  contents: |
    Now we'll deploy the last piece of infrastructure before experiencing the magic of Network Infrastructure Automation w/ Consul Terraform Sync.
tabs:
- title: Current lab setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/7.NIA-Workshop-App_Deploy.html
- title: Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/app
- title: Access Info
  type: code
  hostname: workstation
  path: /access.md
- title: Vault
  type: service
  hostname: workstation
  path: /
  port: 8200
- title: Consul
  type: service
  hostname: workstation
  path: /
  port: 8500
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: workstation
difficulty: basic
timelimit: 3000
---
In this assignment we will be deploying the application into Azure based VMs.

The application uses Consul for Service Discovery. The VMs are configured to run a Consul agent that automatically registers these services into Consul.

Before Consul was implemented, the application relied upon static IP addresses which were hardcoded into the configuration and application code. Now, IP addresses no longer have to be known before the applications can be provisioned. Thus decoupling steps in the provisioning workflow.

Review the code in the `Terraform Code` tab. This defines the VMSS (virtual machine scaling) for the web and app tiers of the application.

Begin provisioning the application in the background:

```
terraform plan
terraform apply -auto-approve
```

By registering nodes and services in Consul, other services can easily discover their health status and network location.

Since the new App and Web services auto-register themselves into Consul, you can now watch the progress of the App deployment by watching the `Consul` tab.

You will explore the environment in more detail in the next challenge.
