---
slug: deploy-services-in-eks
id: 2ontib6im3go
type: challenge
title: Deploy Services in EKS
teaser: A short description of the challenge.
notes:
- type: text
  contents: Replace this text with your own text
tabs:
- title: code - eks
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-eks-services-team2
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 10000
---

Take a look at the terraform code in the `code - eks` tab. In this challenge we will privision on EKS cluster.

Review what the terraform is going to do with:

```sh
terraform plan
```

When ready, deploy with:
```sh
terraform apply -auto-approve
```

Once the `terraform apply` is running, use the credentials in the `Cloud Consoles` tab to login to AWS. Once logged in, navigate to the `Elastic Kubernetes Service`

Before using kubectl we need to specify the location of the kubeconfig file returned by terraform, using the following command:
```sh
export KUBECONFIG=`terraform output -raw kubeconfig_filename`
```

Now verify it works using:
```sh
kubectl get pods
```
