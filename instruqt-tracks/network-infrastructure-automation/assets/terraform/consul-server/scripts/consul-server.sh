#!/bin/bash

#metadata
local_ipv4=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")


#Download Consul
#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main test"

#azure packages
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo apt-key add -
AZ_REPO=$(lsb_release -cs)
sudo apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main"

#install packages
sudo apt update -y
sudo apt install consul-enterprise=1.9.4+ent unzip -y

cat <<EOF>> /etc/consul.d/consul.hcl
{
datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
ca_file = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
}
EOF

cat <<EOF>> /etc/consul.d/server.hcl
{
  server = true
  bootstrap_expect = 1
  client_addr = "0.0.0.0"
  ui = true
  connect {
    enabled = true
  }
}
EOF

chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10
#make sure the config was picked up
sudo service consul restart
