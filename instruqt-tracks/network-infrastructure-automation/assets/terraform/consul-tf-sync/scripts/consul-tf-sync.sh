#!/bin/bash


#vault env
export VAULT_ADDR="http://${vault_addr}"
export VAULT_TOKEN=$vault_token

#packages
sudo apt update -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update -y
apt install consul=1.9.4 vault=1.7.1 unzip -y

#consul config
cat << EOF > /etc/consul.d/consul.hcl
data_dir = "/opt/consul"
ui = true
retry_join = ["${consul_server_ip}"]
EOF

cat << EOF > /etc/consul.d/cts.json
{
  "service": {
    "name": "cts",
    "port": 8558,
    "check": {
      "id": "8558",
      "name": "CTS TCP on port 8558",
      "tcp": "localhost:8558",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF

#Install Consul-Terraform-Sync
curl --silent --remote-name https://releases.hashicorp.com/consul-terraform-sync/0.1.2/consul-terraform-sync_0.1.2_linux_amd64.zip
unzip consul-terraform-sync_0.1.2_linux_amd64.zip
sudo chown root:root consul-terraform-sync
sudo mv consul-terraform-sync /usr/local/bin/
sudo mkdir --parents /etc/consul-tf-sync.d
sudo chown --recursive consul:consul /etc/consul-tf-sync.d
sudo mkdir --parents /opt/consul-tf-sync.d
sudo chown --recursive consul:consul /opt/consul-tf-sync.d

#Create Systemd Config for Consul Terraform Sync
sudo cat << EOF > /etc/systemd/system/consul-tf-sync.service
[Unit]
Description="HashiCorp Consul Terraform Sync - A Network Infra Automation solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul-terraform-sync -config-file=/etc/consul-tf-sync.d/consul-tf-sync-secure.hcl
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/consul-tf-sync.d/consul-tf-sync-secure.hcl
# Global Config Options
log_level = "info"
buffer_period {
  min = "5s"
  max = "20s"
}

# Consul Config Options
consul {
  address = "localhost:8500"
}

vault {
  address = "$${VAULT_ADDR}"
  token   = "${vault_token}"
}

# Terraform Driver Options
driver "terraform" {
  log = true
  path = "/opt/consul-tf-sync.d/"
  working_dir = "/opt/consul-tf-sync.d/"
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
    },
    panos = {
      source = "PaloAltoNetworks/panos"
    }
  }
}

## Network Infrastructure Options

# BIG-IP Workflow Options
terraform_provider "bigip" {
  address = "${bigip_mgmt_addr}:8443"
  username = "${bigip_admin_user}"
  password = "{{ with secret \"secret/f5\" }}{{ .Data.data.password }}{{ end }}"
}

# Palo Alto Workflow Options
terraform_provider "panos" {
  alias = "panos1"
  hostname = "${panos_mgmt_addr}"
#  api_key  = "<api_key>"
  username = "${panos_username}"
  password = "{{ with secret \"secret/pan\" }}{{ .Data.data.password }}{{ end }}"
}

## Consul Terraform Sync Task Definitions

# Load-balancer operations task
task {
  name = "F5-BIG-IP-Load-Balanced-Web-Service"
  description = "Automate F5 BIG-IP Pool Member Ops for Web Service"
  source = "f5devcentral/app-consul-sync-nia/bigip"
  providers = ["bigip"]
  services = ["web"]
}

# Firewall operations task
task {
  name = "DAG_Web_App"
  description = "Automate population of dynamic address group"
  source = "PaloAltoNetworks/ag-dag-nia/panos"
  providers = ["panos.panos1"]
  services = ["web"]
  variable_files = ["/etc/consul-tf-sync.d/panos.tfvars"]
}
EOF

cat << EOF > /etc/consul-tf-sync.d/panos.tfvars
dag_prefix = "cts-addr-grp-"
EOF

#Enable the services
sudo systemctl enable consul
sudo service consul start
sudo service consul status
sudo systemctl enable consul-tf-sync
sudo service consul-tf-sync start
sudo service consul-tf-sync status
