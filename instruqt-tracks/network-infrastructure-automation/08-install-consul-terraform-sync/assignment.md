---
slug: install-consul-terraform-sync
id: 4pa4nyish9os
type: challenge
title: Deploy 'Consul Terraform Sync'
teaser: Now we are going install Consul Terraform Sync and bring dynamic service discovery
  to network infrastructure.
notes:
- type: text
  contents: |
    Now we're going to eliminate a lot of operational friction by installing `consul-terraform-sync`. This will auto-update network infrastructure as service changes occur!
tabs:
- title: Current Lab Setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/8.NIA-Workshop-CTS_Install.html
- title: Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/consul-tf-sync
- title: Shell
  type: terminal
  hostname: workstation
- title: Access Info
  type: code
  hostname: workstation
  path: /access.md
- title: Consul
  type: service
  hostname: workstation
  path: /
  port: 8500
- title: App
  type: service
  hostname: workstation
  path: /ui
  port: 8080
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
difficulty: basic
timelimit: 3000
---
Before installing Consul Terraform Sync, lets take a look at the F5 BIG-IP and the Palo Alto Firewall.

Using the credentials in the `Access Info` tab, open a new browser window and login to the BIG-IP and Palo Alto Firewall.

## BIG-IP Configuration

In the BIG-IP UI, click on 'Local Traffic' > 'Network Map' (a new window will open). In this new window, change the partition from 'Common' to 'All' and then reload the page with `Cmd/Ctrl+R`.

This will be empty. Typically a BIG-IP administrator would now configure the Virtual IP, all the protocol profiles, the monitor, the load-balancer pool, and then add all the web servers to the pool. Consul Terraform Sync is going to take care of this for us.

## Palo Alto Configuration

Switch to the Palo Alto browser tab. Under the 'Policies' tab, note that the second rule "Allow traffic from BIG-IP to App" has a Destination Address Group (DAG) titled "cts-add-grp-web".

Navigate to the "Objects" tab and select "Address Groups". Under the 'Addresses' column for "cts-add-grp-web" click on "more...". Note that the Address Group is empty. Consul Terraform Sync is going to take care of this.

Lastly, in the Lab Console navigate to the 'App' tab and note that the App is not currently available (502 Error).

## Deploy Consul Terraform Sync

Now it's time for Consul Terraform Sync to configure all the Network Infrastructure operations.
```
cd /root/terraform/consul-tf-sync/
terraform plan
terraform apply -auto-approve

```

When completed, you can connect to the CTS image:

```
ssh -q -A -J azure-user@$bastion_ip azure-user@$(curl -s $CONSUL_HTTP_ADDR/v1/catalog/node/consul-terraform-sync | jq -r '.Node.Address')
```

Take a look at the `consul-terraform-sync` configuration
```
cat /etc/consul-tf-sync.d/consul-tf-sync-secure.hcl
```

Review the terraform-consul-sync service status with the following command.
```
service consul-tf-sync status
```

Look over the Palo Alto & BIG-IP configurations again, per the steps above. Note that their configurations have been updated!

Next, navigate to the `App` tab. The application is now available through the Firewall and is Load-balanced. You may need to refresh the tab.

Lastly, navigate back to the 'Current Lab Setup' tab and marvel at the beauty of Network Infrastructure Automation. You did this!

Move to the next assignment when you are ready.
