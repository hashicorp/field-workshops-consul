#!/bin/bash

#Utils
sudo apt-get install unzip

#Download Consul
curl --silent --remote-name https://releases.hashicorp.com/consul/1.8.0+ent/consul_1.8.0+ent_linux_amd64.zip
unzip consul_1.8.0+ent_linux_amd64.zip

#Download Consul Terraform Sync
curl --silent --remote-name https://releases.hashicorp.com/consul-terraform-sync/0.1.0-techpreview2/consul-terraform-sync_0.1.0-techpreview2_linux_amd64.zip
unzip consul-terraform-sync_0.1.0-techpreview2_linux_amd64.zip

#Install Consul
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Install consul-terraform-sync
sudo chown root:root consul-terraform-sync
sudo mv consul-terraform-sync /usr/local/bin/

#Create Consul Terraorm Sync User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo mkdir --parents /opt/consul-tf-sync.d
sudo chown --recursive consul:consul /opt/consul 
sudo chown --recursive consul:consul /opt/consul-tf-sync.d

#Create Systemd Config for Consul
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent  -bind '{{ GetInterfaceIP "eth0" }}' -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

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
ExecStart=/usr/local/bin/consul-terraform-sync -config-file=/etc/consul-tf-sync.d/consul-tf-sync.hcl
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo chown --recursive consul:consul /etc/consul.d

sudo mkdir --parents /etc/consul-tf-sync.d
sudo chown --recursive consul:consul /etc/consul-tf-sync.d

cat << EOF > /etc/consul.d/ca.pem
${ca_cert}
EOF

cat << EOF > /etc/consul.d/hcs.json
${consulconfig}
EOF

cat << EOF > /etc/consul.d/zz_override.hcl
data_dir = "/opt/consul"
ui = true
ca_file = "/etc/consul.d/ca.pem"
acl = {
  tokens = {
    default = "${consul_token}"
  }
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
EOF

cat << EOF > /etc/consul-tf-sync.d/consul-tf-sync.hcl
# Global Config Options
log_level = "info"
buffer_period {
  min = "5s"
  max = "20s"
}

# Consul Config Options
consul {
  address = "localhost:8500"
  token = "${consul_token}"
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
  password = "${bigip_admin_passwd}"
}

# Palo Alto Workflow Options
terraform_provider "panos" {
  alias = "panos1"
  hostname = "${panos_mgmt_addr}"
#  api_key  = "<api_key>"
  username = "${panos_username}"
  password = "${panos_password}"
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

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status

#Enable the service
sudo systemctl enable consul-tf-sync
sudo service consul-tf-sync start
sudo service consul-tf-sync status
