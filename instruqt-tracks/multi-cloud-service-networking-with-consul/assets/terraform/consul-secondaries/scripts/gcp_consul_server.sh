#!/bin/bash

#metadata
local_ipv4=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul-enterprise vault-enterprise google-cloud-sdk jq -y

GCP_ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/zone | cut -d "/" -f4-)
GCP_SA=$(gcloud config get-value account)
export VAULT_ADDR="http://$(gcloud compute instances describe vault-server --zone $GCP_ZONE --format="value(networkInterfaces[0].networkIP)"):8200"
export VAULT_TOKEN=$(vault login -field=token -method=gcp \
  method="iam" \
  role="consul" \
  service_account="$${GCP_SA}")
MASTER_TOKEN=$(vault kv get -field=master_token kv/consul)
REPLICATION_TOKEN=$(vault kv get -field=replication_token kv/consul)
GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
CERT_BUNDLE=$(vault write pki/issue/consul \
    common_name=consul-server-0.server.gcp-us-central-1.consul \
    alt_names="consul-server-0.server.gcp-us-central-1.consul,server.gcp-us-central-1.consul,localhost" \
    ip_sans="127.0.0.1" \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth,ClientAuth" -format=json)

#config
cat <<EOF> /etc/consul.d/server.json
{
  "datacenter": "gcp-us-central-1",
  "primary_datacenter": "aws-us-east-1",
  "server": true,
  "bootstrap_expect": 1,
  "leave_on_terminate": true,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "node_name": "consul-server-0",
  "ui": true,
  "primary_gateways" : ["${primary_wan_gateway}"],
  "connect": {
    "enable_mesh_gateway_wan_federation": true,
    "enabled": true
  }
}
EOF

cat <<EOF> /etc/consul.d/secrets.hcl
acl {
  enabled        = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    master = "$${MASTER_TOKEN}"
    agent  = "$${MASTER_TOKEN}"
    replication = "$${REPLICATION_TOKEN}"
  }
}

encrypt = "$${GOSSIP_KEY}"

EOF

mkdir -p /opt/consul/tls/
echo "$${CERT_BUNDLE}" | jq -r .data.certificate > /opt/consul/tls/server-cert.pem
echo "$${CERT_BUNDLE}" | jq -r .data.private_key > /opt/consul/tls/server-key.pem
echo "$${CERT_BUNDLE}" | jq -r .data.issuing_ca > /opt/consul/tls/ca-cert.pem

cat <<EOF> /etc/consul.d/tls.json
{
  "verify_incoming": true,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ca_file": "/opt/consul/tls/ca-cert.pem",
  "cert_file": "/opt/consul/tls/server-cert.pem",
  "key_file": "/opt/consul/tls/server-key.pem",
  "auto_encrypt": {
    "allow_tls": true
  }
}
EOF

sudo systemctl enable consul.service
sudo systemctl start consul.service

exit 0
