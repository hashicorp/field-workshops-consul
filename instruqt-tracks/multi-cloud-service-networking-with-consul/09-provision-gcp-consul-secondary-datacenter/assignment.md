---
slug: provision-gcp-consul-secondary-datacenter
id: def2vcu1xmjq
type: challenge
title: Provision GCP Consul Secondary Datacenter
teaser: Run Consul in GKE
tabs:
- title: Consul
  type: service
  hostname: cloud-client
  path: /
  port: 8500
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/blob/master/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/diagrams/diagrams.html
- title: Shell
  type: terminal
  hostname: cloud-client
- title: Vault
  type: service
  hostname: cloud-client
  path: /
  port: 8200
- title: Cloud Consoles
  type: service
  hostname: cloud-client
  path: /
  port: 80
- title: Terraform
  type: code
  hostname: cloud-client
  path: /root/terraform/gcp-consul-secondary
- title: Helm
  type: code
  hostname: cloud-client
  path: /root/helm
difficulty: basic
timelimit: 300
---
In this assignment you will bootstrap the GCP secondary Cluster, validate the health of the server and its connection to the primary. <br>

In this environment, Consul on GCP runs entirely in GKE K8s. The Consul helm chart easily supports running Consul in K8s for both Consul server agents, and Consul client agents. <br>

You can read the following resources for more information on running Consul in K8s: <br>
  * https://www.consul.io/docs/k8s
  * https://www.consul.io/docs/k8s/installation/multi-cluster/kubernetes

Inspect the Terraform and provision K8s shared services cluster. <br>

```
terraform plan
terraform apply -auto-approve
```

Check the worker nodes are available for the cluster. <br>

```
gcloud container clusters get-credentials $(terraform output gcp_gke_cluster_shared_name) --region us-central1-a
kubectl config rename-context $(kubectl config current-context) shared
kubectl config use-context shared
kubectl get nodes
```

Now that K8s is ready, you create the K8s federation secret.

```
vault login -method=userpass username=admin password=admin
aws_mgw=$(terraform output -state /root/terraform/aws-consul-primary/terraform.tfstate aws_mgw_public_ip)
server_json=$(jq -n --arg mgw "$aws_mgw" '{primary_datacenter: "aws-us-east-1",primary_gateways:["\($mgw):443"]}')
cat <<EOF | kubectl apply -f -
{
"apiVersion": "v1",
"kind": "Secret",
  "data": {
    "caCert": "$(vault read -field certificate pki/cert/ca | base64 -w 0)",
    "caKey": "$(vault kv get -field private_key kv/pki | base64 -w 0)",
    "gossipEncryptionKey": "$(vault kv get -field gossip_key kv/consul | base64 -w 0)",
    "replicationToken": "$(vault read -field token consul/creds/replication | base64 -w 0)",
    "serverConfigJSON": "$(echo $server_json | base64 -w 0)"
    },
    "metadata": {
        "name": "consul-federation",
        "namespace": "default"
    }
}
EOF
```

Next, deploy the Consul servers. You can review the configuration in the code editor.

```
kubectl create secret generic consul-ent-license --from-literal="key=$(cat /etc/consul.hclic)"
helm install hashicorp hashicorp/consul -f /root/helm/gke-consul-values.yaml --debug --wait --version 0.33.0
```

Check that all three clusters are federated.

```
consul members -wan
```

In the next assignment you will connect Consul secondary components to the server clusters in AWS & Azure.
