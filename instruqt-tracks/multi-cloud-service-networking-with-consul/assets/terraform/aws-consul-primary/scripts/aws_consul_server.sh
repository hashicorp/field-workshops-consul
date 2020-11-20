#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul-enterprise vault-enterprise awscli jq -y

#get the secrets tokens from Vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PublicIpAddress' \
 --output text):8200
vault login -method=aws role=consul
MASTER_TOKEN=$(vault kv get -field=master_token kv/consul)
GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
CERT_BUNDLE=$(vault write pki/issue/consul \
    common_name=consul-server-0.server.aws-us-east-1.consul \
    alt_names="consul-server-0.server.aws-us-east-1.consul,server.aws-us-east-1.consul,localhost" \
    ip_sans="127.0.0.1" \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth,ClientAuth" -format=json)
CONNECT_TOKEN=$(vault token create -field token -policy connect -period 8h)

#config
cat <<EOF> /etc/consul.d/server.json
{
  "datacenter": "aws-us-east-1",
  "primary_datacenter": "aws-us-east-1",
  "server": true,
  "bootstrap_expect": 1,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "node_name": "consul-server-0",
  "ui": true,
  "connect": {
    "enable_mesh_gateway_wan_federation": true,
    "enabled": true,
    "ca_provider": "vault",
    "ca_config": {
      "address": "$${VAULT_ADDR}",
      "token": "$${CONNECT_TOKEN}",
      "root_pki_path": "connect-root/",
      "intermediate_pki_path": "connect-intermediate/"
    }
  }
}
EOF

cat <<EOF> /etc/consul.d/secrets.hcl
acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
  enable_token_persistence = true
  tokens {
    master = "$${MASTER_TOKEN}"
    agent  = "$${MASTER_TOKEN}"
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
