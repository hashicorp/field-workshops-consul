---
slug: provision-network-infra
type: challenge
title: Provision F5 BIG-IP & Palo Alto Firewall
teaser: Provision an F5 BIG-IP VE & Palo Alto Firewall using Terraform
notes:
- type: text
  contents: |
    In this exercise we will be provisioning an F5 BIG-IP Virtual Edition and Palo Alto VM Series Firewall using Terraform.
tabs:
- title: Current lab setup
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/network-infrastructure-automation/assets/images/4.NIA-Workshop-F5_PA.html
- title: Palo Alto Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/panw-vm
- title: F5 BIG-IP Terraform Code
  type: code
  hostname: workstation
  path: /root/terraform/bigip
- title: Shell
  type: terminal
  hostname: workstation
- title: Cloud Consoles
  type: service
  hostname: workstation
  path: /
  port: 80
difficulty: basic
timelimit: 3000
---
First we will provision the Palo Alto Firewall.

In the `Shell` tab run the following commands.
```
cd /root/terraform/panw-vm
terraform plan
terraform apply -auto-approve

```

NOTE: The Palo Alto Firewall will continue to provision in the background allowing you to continue to the next step.

Now we will provision the F5 BIG-IP Virtual Edition using Terraform.

In the `Shell` tab run the following commands.
```
cd /root/terraform/bigip
terraform plan
terraform apply -auto-approve

```

This can take several minutes to complete. While you wait, feel free to look over the `Palo Alto Terraform Code` and `F5 BIG-IP Terraform Code` tabs to see review the Terraform code.

Once the Terraform apply is complete, the BIG-IP is accessible using the IP address provided in the Terraform output.

**NOTE:** You will need to open the BIG-IP URL in a separate browser tab. If you are using chrome, you may be presented with a certificate error. To bypass this error, type "thisisunsafe" into the Chrome window.
