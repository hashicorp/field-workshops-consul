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
timelimit: 2400
---
We already deployed this second EKS cluster in the previous step, in a separate VPC, for the development team. In this cluster we shall deploy Consul and newer version of the HashiCups demonstration application.

We will:
1. Install Consul agents onto k8s
2. Install the HashiCups Dev services
3. Verify the installation


1) Install Consul agents onto k8s
===

```sh
export KUBECONFIG=`terraform output -raw kubeconfig_filename`
```

Verify you can communicate with the EKS Dev cluster:
```sh
kubectl get pods
```

Terraform has generated the helm chart value for you, which we shall now extract and save to a local file:

```sh
terraform output -raw helm_chart | base64 -d > helm.values
```

Use helm to add the hashicorp repo and install the consul client.
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install consul hashicorp/consul --version 0.42.0 --values helm.values
```

*OPTIONAL:* Verify the consul installation:
```sh
helm get all consul | less
```

verify all the pods are up and running.
```sh
kubectl get pods
```

**NOTE:** Unlike the *prod* environment, this cluster supports communication with services outside of EKS using a Consul Mesh Gateway, show in the `Infrastructure Overview` diagram. Mesh Gateways support cross-cluster communication in addition to navigating around challenges like overlapping IP Address ranges.


2) Install the HashiCups Dev services
===

Once the EKS cluster has been bootstrapped into HCP Consul (the previous step) you can install the services. To do so, execute the following command:

```sh
kubectl apply -f /root/terraform/tf-deploy-eks-services-dev/modules/k8s-demo-app/services/
```

You can review the services in the following directort `./modules/k8s-demo-app/services/`.


3) Verify the installation
===

Everything should be deployed and starting up.  Give it a minute and then try to access Hashicups at the ingress gateway url.  Note the newer interface in the dev environmemt.
```
echo "http://$(kubectl get svc consul-eks-dev-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[].hostname')"
```


1. In a sperate tab/window, navigate to the HCP Consul Admin UI using the `consul_url`.
2. To login to consul you will need the `consul_root_token`. To retrieve this, execute: `terraform output consul_root_token`
3. In the HCP Consul UI, select **eks-dev** from the *"Admin Partitions"* list (you may need to reload the page). You should see your newly deployed services registering themselves, and also the **Mesh Gateway**!
4. On the left-hand navigation pane, click *"Intentions"* to see the strict security model. Note the L7 (HTTP) intentions for the frontend security.
5. In *"Services"*, click on the `frontend` service to see how the `intentions` security model is allowing strict communication flows between services.
