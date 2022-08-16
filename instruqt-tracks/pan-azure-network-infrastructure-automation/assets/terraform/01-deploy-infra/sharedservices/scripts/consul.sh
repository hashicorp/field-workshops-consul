#!/bin/bash
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#Utils
sudo apt-get install unzip
sudo apt-get install unzip
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get jq
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform


#Download Consul
CONSUL_VERSION="1.12.2"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Install Consul Terraform Sync

export CTS_CONSUL_VERSION="0.6.0-beta1"
export CONSUL_URL="https://releases.hashicorp.com/consul-terraform-sync"


curl --silent --remote-name \
  ${CONSUL_URL}/${CTS_CONSUL_VERSION}/consul-terraform-sync_${CTS_CONSUL_VERSION}_linux_amd64.zip

curl --silent --remote-name \
  ${CONSUL_URL}/${CTS_CONSUL_VERSION}/consul-terraform-sync_${CTS_CONSUL_VERSION}_SHA256SUMS

curl --silent --remote-name \
  ${CONSUL_URL}/${CTS_CONSUL_VERSION}/consul-terraform-sync_${CTS_CONSUL_VERSION}_SHA256SUMS.sig

#Unzip the downloaded package and move the consul binary to /usr/bin/. Check consul is available on the system path.

unzip consul-terraform-sync_${CTS_CONSUL_VERSION}_linux_amd64.zip
mv consul-terraform-sync /usr/local/bin/consul-terraform-sync

sudo mkdir --parents /opt/consul


#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

cat << EOF > /etc/consul.d/consul.hcl
datacenter = "AcademyDC1"
data_dir = "/opt/consul"
server = true
bootstrap_expect = 1

client_addr = "0.0.0.0"
ui = true
EOF


#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status


