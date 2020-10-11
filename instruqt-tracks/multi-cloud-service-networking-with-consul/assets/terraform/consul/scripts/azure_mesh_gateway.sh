#!/bin/bash

#metadata
local_ipv4="$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")"
public_ipv4="$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")"

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul -y

#config
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "azure-west-us-2",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=azure tag_name=Env tag_value=${} subscription_id=${}],
  "ui": true,
  "connect": {
    "enabled": true
  },
  "ports": {
    "grpc": 8502
  }
}
EOF


mkdir -p /opt/consul/tls/
echo "${ca_cert}" > /opt/consul/tls/ca-cert.pem

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

sleep 30

curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.14.1
cp /root/.getenvoy/builds/standard/1.14.1/linux_glibc/bin/envoy /usr/local/bin/envoy
nohup consul connect envoy -expose-servers -gateway=mesh -register -service "mesh-gateway" -address "$${local_ipv4}:443" -wan-address "$${public_ipv4}:443" -- -l debug > /envoy.out &
exit 0
