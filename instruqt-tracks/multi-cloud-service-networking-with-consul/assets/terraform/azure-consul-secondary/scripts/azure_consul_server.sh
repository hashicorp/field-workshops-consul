#!/bin/bash

#metadata
local_ipv4=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul-enterprise vault-enterprise jq -y

#azure cli
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli

#get secrets
az login --identity
export VAULT_ADDR="http://$(az vm show -g $(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .resourceGroupName') -n vault-server-vm -d | jq -r .publicIps):8200"
export VAULT_TOKEN=$(vault write -field=token auth/azure/login -field=token role="consul" \
     jwt="$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true | jq -r '.access_token')")
 MASTER_TOKEN=$(vault kv get -field=master_token kv/consul)
 REPLICATION_TOKEN=$(vault kv get -field=replication_token kv/consul)
 GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
 CERT_BUNDLE=$(vault write pki/issue/consul \
     common_name=consul-server-0.server.azure-west-us-2.consul \
     alt_names="consul-server-0.server.azure-west-us-2.consul,server.azure-west-us-2.consul,localhost" \
     ip_sans="127.0.0.1" \
     key_usage="DigitalSignature,KeyEncipherment" \
     ext_key_usage="ServerAuth,ClientAuth" -format=json)
CONNECT_TOKEN=$(vault token create -field token -policy connect -period 8h)

#config
cat <<EOF> /etc/consul.d/server.json
{
  "datacenter": "azure-west-us-2",
  "primary_datacenter": "aws-us-east-1",
  "server": true,
  "bootstrap_expect": 1,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "node_name": "consul-server-0",
  "ui": true,
  "primary_gateways" : ["${primary_wan_gateway}"],
  "connect": {
    "enable_mesh_gateway_wan_federation": true,
    "enabled": true,
    "ca_provider": "vault",
    "ca_config": {
      "address": "$${VAULT_ADDR}",
      "token": "$${CONNECT_TOKEN}",
      "root_pki_path": "connect-root/",
      "intermediate_pki_path": "connect-intermediate-west/"
    }
  }
}
EOF

cat <<EOF> /etc/consul.d/secrets.hcl
acl {
  enabled        = true
  default_policy = "deny"
  down_policy = "extend-cache"
  enable_token_persistence = true
  enable_token_replication = true
  tokens {
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
