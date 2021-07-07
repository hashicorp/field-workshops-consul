#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PrivateIpAddress' \
 --output text):8200
vault login -method=aws role=consul
AGENT_TOKEN=$(vault kv get -field=master_token kv/consul)
GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
CA_CERT=$(vault read -field certificate pki/cert/ca)

#consul
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "aws-us-east-1",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=aws tag_key=Env tag_value=consul-${env}"],
  "ui": true,
  "connect": {
    "enabled": true
  },
  "ports": {
    "grpc": 8502
  }
}
EOF

cat <<EOF> /etc/consul.d/secrets.hcl
acl {
  enabled        = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    agent  = "$${AGENT_TOKEN}"
  }
}

encrypt = "$${GOSSIP_KEY}"

EOF

mkdir -p /opt/consul/tls/
echo "$${CA_CERT}" > /opt/consul/tls/ca-cert.pem

cat <<EOF> /etc/consul.d/tls.json
{
  "verify_incoming": false,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ca_file": "/opt/consul/tls/ca-cert.pem",
  "auto_encrypt": {
    "tls": true
  }
}
EOF

sudo systemctl enable consul.service
sudo systemctl start consul.service

#nomad
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
modprobe br_netfilter
sysctl -p /etc/sysctl.conf
echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

mkdir -p /etc/nomad.d/
mkdir -p /opt/nomad

cat <<EOF> /etc/nomad.d/nomad.hcl
datacenter = "aws-us-east-1"
data_dir = "/opt/nomad"
EOF

cat <<EOF> /etc/nomad.d/client.hcl
client {
  enabled = true
  meta {
      "connect.sidecar_image" = "envoyproxy/envoy:v1.16.2"
  }
}
EOF

cat <<EOF> /etc/nomad.d/consul.hcl
consul {
  token = "$${AGENT_TOKEN}"
}
EOF

cat <<EOF> /etc/nomad.d/vault.hcl
vault {
  enabled          = true
  address          = "$${VAULT_ADDR}"
  create_from_role = "nomad-cluster"
}
EOF

sudo systemctl enable nomad.service
sudo systemctl start nomad.service

exit 0
