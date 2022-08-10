---
slug: deploy-services-in-ecs

type: challenge
title: Deploy Services in ECS for the New Dev team
teaser: Now we are going to deploy an ECS cluster for the new front-end team, which
  will use the EKS backend, securely...
notes:
- type: text
  contents: In this section we're going to create an ECS cluster and deploy only the
    HashiCups UI and Public API for a new dev team. These services will securely connect
    to the "Product-API" and "Payments" services in EKS Dev.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - ECS Dev
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-ecs-services-dev
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 3000
---
In this challenge we're going to build an Elastic Container Service (ECS) Cluster in its own VPC – the far right VPC in the `Infrastructue Overview` diagram. Upon this ECS cluster we will deploy the HashiCups "frontend" and "public-api" services, which will have upstreams to the *"product-api"* and *"payments"* services in the EKS dev cluster.

Objectives covered in this challenge:
1. Create an ECS Cluster and deploy services
2. Review the ECS deployment
3. Review the cross-platform Mesh Gateway access


1) Create an ECS Cluster and deploy services
===

First we are going to create and ECS Cluster upon which we will deploy these two internet facing services, `frontend` and `public-api`. using terraform. To review the infrastructure you will create, execute the following command:

```sh
terraform plan
```

When ready, deploy this infrastructure and services with:

```sh
nohup terraform apply -auto-approve > /root/terraform/tf-deploy-ecs-services-dev/ecs_dev.out &
```

You can monitor the progress of the deployment using the following command:

```sh
tail -f /root/terraform/tf-deploy-ecs-services-dev/ecs_dev.out
```

While this is running we can review what terraform is building. Navigate to the `code - ECS Dev` tab:
1. Review `ecs-cluster.tf` - this creates a FARGATE ECS Cluster.
2. Review `acl_controller.tf` - to ensure that your ECS Services are secure, the `acl_controller` manages the Consul ACL tokens and roles/policies for the deploted ECS tasks.
3. Review `services-frontend.tf` and `services-public-api.tf` - they are both examples of creating ECS tasks, and the containers required to implement secure service networking for the service. `mesh-task` bootstraps the local consul agent and envoy proxy sidecar service, and registers the frontend/public-api with consul, before then shutting itself down - its only there to bootstrap and will also return to STOPPED status.

Once the `terraform apply` has completed you may move onto the next section below.

NOTE: the `hashicups_url` will not work yet as ECS is still launching the ECS tasks. It shall be running shortly.

2) Review the ECS deployment
===

Now that we have a cluster running, and ECS Tasks defined, we'll take a look at what we've built.

1. In the AWS Console, enter "ECS" in the search bar and select *"Elastic Container Service"*
2. In the overview page, click on the *"consul-ecs"* cluster to see the list of services that have been deployed.
3. In the 'tasks' tab you will see our new services launching. They will soon report "RUNNING", after which the service behind the `hashicups_url` will be ready.
4. In the Consul UI, navigate to the *"ecs-dev"* partition (you may need to reload the page). Once the `mesh-init` task has bootstrapped the environment, the services have launched and registered themselves, they will appear here. You should see `frontend`, `public-api`, and `mesh-gateway` services.
5. In the left-hand navigation pane, click on *"Intentions"*. Note that the intetions list the source and destination partitions, allowing communications across the Consul Admin Partitions.

If you're ECS Tasks are now up and running (you can check in AWS Console) the Hashicups URL should now load. Once this is loaded, and the application is running, you may progress to the next setion below.

3) Review the cross-platform Mesh Gateway access
===

Consul Admin Partitions enables a shared Consul control-plane across separate, isolated platforms, but can also facilitate secure communications amongst those share platforms.

This capability enables both infrastructure consolidation and operational simplification:
* One Consul cluster for many platforms.
* A common set of policies/intentions to manage zero trust secure service networking.

In this final section we will recap what we've built here.

1. Navigate to the `Infrastructure Overview` tab. Per the diagram, we've created a shared platform to manage the secure control-planes for both an isolated production deployment, and two seperate development environments with a *service specific* intention allowing mTLS authenticated, one-way communication between specific source and destination service identities: the ECS hosted `public-api` service to the EKS hosted `product-api` and `payments` services.
2. Navigate to the `code - ECS Dev` tab. Review the `consul-exported-services.tf`, permitting the `product-api` and `payments` services to be visible to the `ecs-dev` partition, and the `consul-intentions.tf` defining the security policies for these services - in this case implemented using an infrastructure-as-code model via terraform and the consul provider.
3. Also in the `code - ECS Dev`, review the `mesh-gw.tf` and `scripts/ecs_-_mesh_gw.sh`. You may have already noticed that the Mesh Gateway is not listed as an ECS task. Per the `mesh-gw.tf`, we have deployed this as an EC2 instance in the same VPC as ECS. Consul runs everywhere!
4. Lastly, desmontrating the simplicity, yet secure effectiveness of the Service Identity-based networking we are going to disable the Consuul intention between the `public-api` service in ECS and the `product-api` service in EKS:
   1. In the Consul UI, via the left-hand navigation pane, select "*Intentions*".
   2. In the list, click on the Intention with the "Source" `public-api` and the destination `product-api`.
   3. In the next screen that loads, select **"DENY"**, and click Save.
   4. Return to the HashiCups demonstration application and reload the page. Due to browser caching you may need to reload twice. You shoud now see a message altering you that it is "Unable to query all coffees".
   5. Return the intention back to the "ALLOW" state, click Save, and reload the app once again.

NOTE: this Service Identity model UX is the same with 1 instance of a service, as we have in this simple lab environment, or 1000 instances of the service. The policies, intentions, and communications are a facet of service identity.


This concludes our Instruqt Workshop on "Secure Service Networking for AWS".