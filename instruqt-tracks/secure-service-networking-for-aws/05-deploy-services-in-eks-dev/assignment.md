---
slug: deploy-services-in-eks-dev

type: challenge
title: Deploy Services in EKS for the Dev Team
teaser: Let's deploy some microservices on EKS for the development team!
notes:
- type: text
  contents: In this section you will create an EKS cluster and deploy some services.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-eks-dev-lab.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - EKS Dev
  type: code
  hostname: shell
  path: /root/terraform/tf-deploy-eks-services-dev
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
In this challenge we're going to build a second EKS cluster, in a separate VPC, for the development team. In this cluster we shall deploy a newer version of the HashiCups demonstration application.

We will:
1. Create an EKS (K8s) cluster and deploy the newer microservices-based application
2. Verify the installation


1) Deploy EKS Dev and Newer Services
===

This deployment, depicted in the center of the `Infrastructure Overview` diagram, is very similar to the previous cluster, so we shall get the terraform deployment started first, before reviewing the differences, with the following command:
```sh
nohup terraform apply -auto-approve > /root/terraform/tf-deploy-eks-services-dev/eks_dev.out &
```

You can monitor the progress of the deployment using the following command:

```sh
tail -f /root/terraform/tf-deploy-eks-services-dev/eks_dev.out
```

**NOTE:** Unlike the *prod* environment, this cluster supports communication with services outside of EKS using a Consul Mesh Gateway, show in the `Infrastructure Overview` diagram. Mesh Gateways support cross-cluster communication in addition to navigating around challenges like overlapping IP Address ranges.

While that is runnning, lets take a look at what's different with this deployment. Navigate to the `code - EKS Dev` tab:
1. In the `./modules/hcp-eks-client` directoy you can see the helm chart to install consul onto EKS. Take a look in `./modules/hcp-eks-client/templates/consul.tpl`. Note the unique `name` and `adminParitions.name:` We shall see a new partition created in the HCP Consul UI with this partition name. Also note that near the bottom of the helm chart we have enabled `meshGateway` in this install. The **Mesh Gateway** will enable cross-partition communication in a later workshop challenge.  You will manually install the helm chart next.

2. In the `./modules/k8s-demo-app/services/` directory there's a different list of services for the new version of HashiCups.  After installing the helm chart you will use kubectl to install these services and finish the deployment of the EKS cluster.

3) Connect to EKS
===

Once the `terraform apply` is complete connect to EKS to finish installing the helm chart and services.
```sh
export KUBECONFIG=`terraform output -raw kubeconfig_filename`
```

Use helm to add the hashicorp repo and install the consul client.
```sh
terraform output -raw helm_chart | base64 -d > helm.values
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install consul hashicorp/consul --version 0.42.0 --values helm.values
helm status consul
```

verify all the pods are up and running.
```sh
kubectl get pods
```

Once the EKS cluster has been bootstrapped into HCP Consul install the services.
```sh
kubectl apply -f /root/terraform/tf-deploy-eks-services-dev/modules/k8s-demo-app/services/
```

Everything should be deployed and starting up.  Give it a minute and then try to access Hashicups at the ingress gateway url.  Note the newer interface in the dev environmemt.
```
echo "http://$(kubectl get svc consul-eks-dev-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[].hostname')"
```


1. In a sperate tab/window, navigate to the HCP Consul Admin UI using the `consul_url`.
2. To login to consul you will need the `consul_root_token`. To retrieve this, execute: `terraform output consul_root_token`
3. In the HCP Consul UI, select **eks-dev** from the *"Admin Partitions"* list (you may need to reload the page). You should see your newly deployed services registering themselves, and also the **Mesh Gateway**!
4. On the left-hand navigation pane, click *"Intentions"* to see the strict security model. Note the L7 (HTTP) intentions for the frontend security.
5. In *"Services"*, click on the `frontend` service to see how the `intentions` security model is allowing strict communication flows between services.

