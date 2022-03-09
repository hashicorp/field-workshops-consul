---
slug: provision-cloud-infra
id: ztvfzu8kpo7y
type: challenge
title: Provision Cloud Infrastructure
teaser: Create cloud VPCs
notes:
- type: text
  contents: |
    You are being provisioned on-demand cloud infrastructure. <br>
    Please be patient as this can take up to ~15 minutes.
tabs:
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/infra
- title: Packer
  type: code
  hostname: cloud-client
  path: /root/packer
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 300
---
The terraform code will provision cloud infrastructure in AWS, GPC, and Azure. <br>

Your lab environment will leverage pre-built packer images.
You can inspect the image build in the code editor, and validate the images are available in AWS & Azure. <br>

```
az image list -g packer | jq
aws ec2 describe-images --owners self | jq
```

Inspect the terraform code and validate the VPCs and VNets that were pre-provisioned for shared services and application workloads. <br>

```
aws ec2 describe-vpcs
gcloud compute networks list
az network vnet list
```

If you get an error on your Packer images, you can rebuild either image below from the packer directory:

```
cd /root/packer/
```

* AWS - `packer build -force -only=amazon-ebs-ubuntu-bionic hashistack.json`
* AZURE - `packer build -force -only=azure-ubuntu-bionic hashistack.json`

In the next few challenges we will centralize secrets across environments.
