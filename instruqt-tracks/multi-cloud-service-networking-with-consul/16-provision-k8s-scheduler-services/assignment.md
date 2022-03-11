---
slug: provision-k8s-scheduler-services
id: abf0py1yysbv
type: challenge
title: Provision K8s Scheduler Services
teaser: Deploy K8s workload infrastructure
tabs:
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/k8s-scheduler-services
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Helm
  type: code
  hostname: cloud-client
  path: /root/helm
difficulty: basic
timelimit: 500
---
In this assignment you will provision K8s workload clusters in GCP.
These clusters will connect to the shared services Consul GKE cluster in GCP. <br>

You can read the docs for more information on these patterns: <br>

* [Overview](https://www.consul.io/docs/k8s)
* [Multi-Cluster](https://www.consul.io/docs/k8s/installation/multi-cluster)

Inspect the Terraform and provision the K8s clusters. <br>

```
terraform plan
terraform apply -auto-approve
```

Next, configure the two provisioned workload K8s clusters and connect them to the shared svcs cluster.


First, deploy the React cluster. <br>

```
vault login -method=userpass username=admin password=admin
gcloud container clusters get-credentials $(terraform output -state /root/terraform/k8s-scheduler-services/terraform.tfstate gcp_gke_cluster_react_name) --region us-central1-a
kubectl config rename-context $(kubectl config current-context) react
kubectl config use-context react
kubectl create secret generic hashicorp-consul-ca-cert --from-literal="tls.crt=$(vault read -field certificate pki/cert/ca)"
kubectl create secret generic hashicorp-consul-gossip-key --from-literal="key=$(vault kv get -field=gossip_key kv/consul)"
kubectl create secret generic bootstrap-token --from-literal="token=$(vault read -field token consul/creds/operator)"
helm install consul hashicorp/consul --set externalServers.k8sAuthMethodHost="https://$(terraform output gcp_gke_cluster_react_endpoint)" -f /root/helm/react-consul-values.yaml --debug --wait --timeout 10m --version 0.33.0
helm list -a
```

Last, deploy the Graphql cluster. <br>

```
vault login -method=userpass username=admin password=admin
gcloud container clusters get-credentials $(terraform output -state /root/terraform/k8s-scheduler-services/terraform.tfstate gcp_gke_cluster_graphql_name) --region us-central1-a
kubectl config rename-context $(kubectl config current-context) graphql
kubectl config use-context graphql
kubectl create secret generic hashicorp-consul-ca-cert --from-literal="tls.crt=$(vault read -field certificate pki/cert/ca)"
kubectl create secret generic hashicorp-consul-gossip-key --from-literal="key=$(vault kv get -field=gossip_key kv/consul)"
kubectl create secret generic bootstrap-token --from-literal="token=$(vault read -field token consul/creds/operator)"
helm install consul hashicorp/consul --set externalServers.k8sAuthMethodHost="https://$(terraform output gcp_gke_cluster_graphql_endpoint)" -f /root/helm/graphql-consul-values.yaml --debug --wait --timeout 10m --version 0.33.0
helm list -a
```

The K8s nodes are now registered in the Consul catalog.

```
consul catalog nodes -datacenter gcp-us-central-1
```

In later assignments you will use these clusters to run frontend application workloads.
