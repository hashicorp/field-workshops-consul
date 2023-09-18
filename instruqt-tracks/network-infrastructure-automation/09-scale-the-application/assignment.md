---
slug: scale-the-application
type: challenge
title: Scale the application
teaser: Let Consul take care of routine adds/moves/changes of services instances.
notes:
- type: text
  contents: |
    75% companies surveyed take Days or even Weeks to complete networking tasks.

    Organizations seeking to improve application delivery cycle are often blocked at the networking layer

    [source](https://zkresearch.com/research/2017-application-delivery-controller-study)
tabs:
- title: Current lab setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/9.NIA-Workshop-App_Scale.html
- title: Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/app
- title: Shell
  type: terminal
  hostname: workstation
- title: Shell
  type: terminal
  hostname: workstation
- title: Access Info
  type: code
  hostname: workstation
  path: /access.md
- title: App
  type: service
  hostname: workstation
  path: /ui
  port: 8080
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
difficulty: basic
timelimit: 3000
---
In this assignment we will watch CTS run as we scale up the application. Tail the CTS logs in one of the shells.

```
ssh -q -A -J azure-user@$bastion_ip azure-user@$(curl -s $CONSUL_HTTP_ADDR/v1/catalog/node/consul-terraform-sync | jq -r '.Node.Address') journalctl -u consul-tf-sync -f
```

Now let's re-run the Terraform code for the application in the other shell, with some new variables to scale the application out:

```
terraform apply -var app_count=3 -var web_count=3 -auto-approve
```

After the Terraform run completes, you can monitor the status of your nodes and services using the Consul UI. Once all of the new instances are online and healthy, you can revisit some of the things we reviewed in the previous exercises.

View the nodes and services via CLI:

```
consul members
consul catalog services

```

Review all of the web instances:
```
curl -s $CONSUL_HTTP_ADDR/v1/catalog/service/web | jq
```

Review all of the app instances:
```
curl -s $CONSUL_HTTP_ADDR/v1/catalog/service/app | jq
```

Once the new instances have finished booting, review the Palo Alto address group and the BIG-IP Pool member list once again and note that they now have three addresses to
reflect the increased server scale group.

The resources for this lab will self-destruct in 8 hours, but to save a little money, **please scale the application back down.**

Re-run Terraform, and monitor the various integration points once again. We'll do so in the background so that you can move on whenever you're ready.

```
nohup terraform apply -var app_count=1 -var web_count=1 -auto-approve > /root/terraform/app/scaledown.out &
```

This concludes the final step in the Network Infrastructure Automation workshop.
