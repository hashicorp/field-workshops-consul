---
slug: deploy-services-in-eks-prod
id: xz2ckg5ywlrj
type: challenge
title: Deploy Services in EKS for the Prod Deployment
teaser: Let's deploy some microservices on EKS for the production deployment!
notes:
- type: text
  contents: In this section you will create the Production EKS cluster and deploy
    some services.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - EKS Prod
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
timelimit: 1200
---
In this challenge we're going to build the customer-facing prouction deployment.

We will:
1. Create an EKS (K8s) cluster and deploy a microservices-based application
2. Verify the installation



1) Deploy EKS Prod and Services
===

We are now going to create an EKS cluster upon which we will deploy a microservices-based application called **HashiCups**, as depicted in the far left of the `Infrastructure Overview` diagram.

First, review the infrastructure you will build with the following command:

```sh
terraform plan
```

When ready, deploy with:
```sh
nohup terraform apply -auto-approve > /root/terraform/tf-deploy-eks-services-prod/eks_prod.out &
```

NOTE: EKS clusters take approximately 15 minutes to create and you will be asked to create a second cluster for dev in the next challenge.  To only wait once kick off the dev build in the background now or .
```
cd /root/terraform/tf-deploy-eks-services-dev
terraform init
nohup terraform apply -auto-approve > /root/terraform/tf-deploy-eks-services-dev/eks_dev.out &
```

Monitor the progress of the EKS Prod deployment using the following command:

```sh
cd /root/terraform/tf-deploy-eks-services-prod
tail -f /root/terraform/tf-deploy-eks-services-prod/eks_prod.out
```

While that is runnning, lets take a closer look at what we're creating:
1. Take a look at the terraform code in the `code - EKS Prod` tab.
   1. In the root directory you will see how we create the EKS Cluster - `main.tf`.
   2. In the `./modules/hcp-eks-client` directoy you can see the helm chart that installs consul onto EKS.
   3. In the `./modules/k8s-demo-app/services/` directory you can see the services we're deploying.

2. In the AWS Console tab type "EKS" and select "Elastic Kubernetes Service" to monitor what we're building on AWS. Once the cluster has been created you can click on the cluster name and:
   1. View the nodes upon which k8s is running in the *Overview* tab.
   2. View both k8s core services and the demonstration app's deployed microservices in the *Workloads* tab.

2) Verify the installation
===

Once the `terraform apply` is complete you should see five `terraform output` values. Please follow these steps:

1. In a sperate tab/window, navigate to the HCP Consul Admin UI using the `consul_url`.
2. To login to consul you will need the `consul_root_token`. To retrieve this, execute: `terraform output consul_root_token`
3. In the HCP Consul UI, select **eks-prod** from the *"Admin Partitions"* list (you may need to reload the page). You should see your newly deployed services registering themselves.
4. On the left-hand navigation pane, click *"Intentions"* to see the strict security model. Not the L7 (HTTP) intentions for the frontend security.
5. In *"Services"*, click on the `frontend` service to see how the `intentions` security model is allowing strict communication flows between services.
6. In a sperate tab/window, navigate to the the microservice-based demonstration application, HashiCups, using the `hashicups_url` output value.
7. Next, we are going to use `kubectl` command to list the k8s pods we have just deployed. Before using the `kubectl` command we need `export` the location of the `kubeconfig` file returned by terraform as an environment variable. To do this execute the following command:

```sh
export KUBECONFIG=`terraform output -raw kubeconfig_filename`
```

Now you can verify it works using:
```sh
kubectl get pods
```
