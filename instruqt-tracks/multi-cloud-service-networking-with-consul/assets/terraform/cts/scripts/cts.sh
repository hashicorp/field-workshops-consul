#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
instance="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

#vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PrivateIpAddress' \
 --output text):8200

#dirs
mkdir -p /etc/vault-agent.d/
mkdir -p /opt/consul/tls/
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/

#vault-agent template
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/jwt-template.ctmpl
{{ with secret "identity/oidc/token/consul-aws-us-east-1" }}{{ .Data.token }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/cts-service-template.ctmpl
{
  "service": {
    "name": "cts",
    "token": "{{ with secret "consul/creds/cts" }}{{ .Data.token }}{{ end }}",
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
cat <<EOF> /etc/vault-agent.d/cts-template.ctmpl
log_level = "INFO"
port = 8558
syslog {}
buffer_period {
  enabled = true
  min = "5s"
  max = "20s"
}
working_dir = "/opt/consul-tf-sync.d/"
consul {
    address =  "localhost:8500"
    token   =  "{{ with secret "consul/creds/cts" }}{{ .Data.token }}{{ end }}"
}
task {
  name           = "security-group-demo-task"
  description    = "allow all redis TCP traffic from specific source to a security group"
  source         = "github.com/hashicorp/field-workshops-consul/instruqt-tracks/multi-cloud-service-networking-with-consul/assets/terraform/cts/ctsmodule"
  services       = ["consul-esm", "aws-us-east-1-terminating-gateway"]
  variable_files = ["/home/ubuntu/security_input.tfvars"]
}
driver "terraform" {
  log = true
  path = "/opt/consul-tf-sync.d/"
  working_dir = "/opt/consul-tf-sync.d/"
}
EOF

#vault-agent
cat <<EOF> /etc/vault-agent.d/vault.hcl
pid_file = "/var/run/vault-agent-pidfile"
auto_auth {
  method "aws" {
      mount_path = "auth/aws"
      config = {
          type = "iam"
          role = "consul"
      }
  }
}
template {
  source      = "/etc/vault-agent.d/consul-ca-template.ctmpl"
  destination = "/opt/consul/tls/ca-cert.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/jwt-template.ctmpl"
  destination = "/etc/consul.d/token"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/cts-service-template.ctmpl"
  destination = "/etc/consul.d/cts.json"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/cts-template.ctmpl"
  destination = "/etc/consul-tf-sync.d/cts.hcl"
  command     = "sudo service consul-tf-sync restart"
}
vault {
  address = "$${VAULT_ADDR}"
}
EOF

cat <<EOF > /etc/systemd/system/vault-agent.service
[Unit]
Description=Vault-agent
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/vault agent -config=/etc/vault-agent.d/vault.hcl -log-level=debug
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
sudo vault agent -config=/etc/vault-agent.d/vault.hcl -log-level=debug -exit-after-auth

#consul
cat <<EOF> /etc/consul.d/consul.hcl
datacenter = "aws-us-east-1"
primary_datacenter = "aws-us-east-1"
advertise_addr = "$${local_ipv4}"
client_addr = "0.0.0.0"
node_name = "$${instance}"
ui = true
connect = {
  enabled = true
}
retry_join = ["provider=aws tag_key=Env tag_value=consul-${env}"]
license_path="/etc/consul.d/consul.hclic"
data_dir = "/opt/consul/data"
log_level = "INFO"
ports = {
  grpc = 8502
}
EOF
cat <<EOF> /etc/consul.d/tls.hcl
ca_file = "/opt/consul/tls/ca-cert.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
EOF
cat <<EOF> /etc/consul.d/auto.json
{
  "auto_config": {
    "enabled": true,
    "intro_token_file": "/etc/consul.d/token",
    "server_addresses": [
      "provider=aws tag_key=Env tag_value=consul-${env}"
    ]
  }
}
EOF
sudo systemctl enable consul.service
sudo systemctl start consul.service

#!/bin/bash

#Utils
sudo apt-get install unzip
#Download Consul Terraform Sync
curl --silent --remote-name https://releases.hashicorp.com/consul-terraform-sync/0.4.3/consul-terraform-sync_0.4.3_linux_amd64.zip
unzip consul-terraform-sync_0.4.3_linux_amd64.zip

#Install consul-terraform-sync
sudo chown root:root consul-terraform-sync
sudo mv consul-terraform-sync /usr/local/bin/

#Create Consul Terraform Sync User
#Use if needed, for now, manually enable it.
#sudo useradd --system --home /etc/consul.d --shell /bin/false consul

sudo mkdir --parents /opt/consul-tf-sync.d
sudo chown --recursive consul:consul /opt/consul-tf-sync.d

#Create Systemd Config for Consul Terraform Sync
#copy and use if needed, for now, manually enable it.

#Create config dir
#Use if needed, for now, manually enable it.
sudo mkdir --parents /etc/consul-tf-sync.d
sudo chown --recursive consul:consul /etc/consul-tf-sync.d


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
ExecStart=/usr/local/bin/consul-terraform-sync -config-file=/etc/consul-tf-sync.d/cts.hcl
KillMode=process
Restart=always
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Enable the services
sudo systemctl enable consul
sudo service consul start
sudo service consul status
sudo systemctl enable consul-tf-sync
sudo service consul-tf-sync start
sudo service consul-tf-sync status
#start the vault-agent
sleep 30
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service
exit 0
