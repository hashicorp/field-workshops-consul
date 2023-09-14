---
slug: configure-palo-alto-firewall
id: 7vltkulroiy8
type: challenge
title: Configure Palo Alto Firewall
teaser: Provision a Palo Alto VM-Series Firewall using Terraform.
notes:
- type: text
  contents: Next we shall configure the newly deployed Palo Alto virtual machine.
tabs:
- title: Provision PANW
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/4.NIA-Workshop-F5_PA.html
- title: Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/panw-config
- title: Shell
  type: terminal
  hostname: workstation
- title: Access Info
  type: code
  hostname: workstation
  path: /access.md
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
difficulty: basic
timelimit: 300
---
Now we will configure the Palo Alto Firewall using Terraform.

 First, verify that the Palo Alto VM firewall setup has completed.
 In the `Shell` tab run the following command:

 ```
tail /root/terraform/panw-vm/nohup.out -n 12
```

 You should see `Apply complete!`. If it hasn't finished yet, review the Terraform code that will be used to configure the firewall, in the 'Terraform Code' tab.

When ready, configure the firewall:

 ```
terraform plan
terraform apply -auto-approve

```

Once the apply has completed, Open up new browser tabs to access the Palo Alto and BIG-IP Virtual Machines using the details in the 'Access Info' tab.

For CLI access to the Firewall execute:
```
ssh -q -A -J azure-user@$bastion_ip paloalto@$firewall_ip
```
