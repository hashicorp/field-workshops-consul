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
rm -rf /etc/consul.d/*

cat <<-EOF > /etc/consul.d/server.hcl
{
  datacenter = "dc1",
  bind_addr = "0.0.0.0",
  client_addr = "0.0.0.0",
  data_dir = "/etc/consul.d",
  log_level = "INFO",
  node_name = "ConsulServer",
  server = true,
  ui = true,
  bootstrap_expect = 1,
}
EOF

chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10
#make sure the config was picked up
sudo service consul restart
