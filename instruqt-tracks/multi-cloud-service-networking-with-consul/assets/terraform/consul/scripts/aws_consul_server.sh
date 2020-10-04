#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul -y

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
    "enabled": true
  }
}
EOF

mkdir -p /opt/consul/tls/
echo "${ca_cert}" > /opt/consul/tls/ca-cert.pem
echo "${cert}" > /opt/consul/tls/server-cert.pem
echo "${key}" > /opt/consul/tls/server-key.pem

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
