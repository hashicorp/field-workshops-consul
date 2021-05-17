#!/bin/bash

#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#consul
sudo apt update -y
sudo apt install consul-enterprise=1.9.4+ent unzip -y
rm -rf /etc/consul.d/*

cat <<-EOF > /etc/consul.d/consul.hcl
datacenter = "dc1"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
data_dir = "/etc/consul.d"
log_level = "INFO"
node_name = "ConsulServer"
server = true
ui = true
bootstrap_expect = 1
EOF

chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
