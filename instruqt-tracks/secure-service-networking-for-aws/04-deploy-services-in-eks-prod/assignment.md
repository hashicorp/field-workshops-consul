---
slug: deploy-services-in-eks-prod
id: n1oadiz2ylrp
type: challenge
title: Deploy Services in EKS for the Prod Deployment
teaser: Let's deploy some microservices on EKS for the production deployment!
notes:
- type: video
  url: ../assets/video/SSN4AWS-Challenge4.mp4
- type: text
  contents: In this section you will create an EKS cluster and deploy some services.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: App Architecture Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-app-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - eks
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-eks-services-prod
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
nohup terraform apply -auto-approve > /root/terraform/tf-deploy-eks-services-prod/eks_prod.out &
```

NOTE: we run this in the background (`nohup` / `&`) so that it continues even if your communication with the Instruqt platform is interrupted.

You can monitor the progress of the deployment using the following command:

```sh
tail -f /root/terraform/tf-deploy-eks-services-prod/eks_prod.out
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
