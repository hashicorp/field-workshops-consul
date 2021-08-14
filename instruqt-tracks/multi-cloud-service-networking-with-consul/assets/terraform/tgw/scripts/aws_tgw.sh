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

#vault-agent
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/envoy-token-template.ctmpl
{{ with secret "consul/creds/aws-tgw" }}{{ .Data.token }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/jwt-template.ctmpl
{{ with secret "identity/oidc/token/consul-aws-us-east-1" }}{{ .Data.token }}{{ end }}
EOF
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
  source      = "/etc/vault-agent.d/envoy-token-template.ctmpl"
  destination = "/etc/envoy/consul.token"
  command     = "sudo service envoy restart"
}
template {
  source      = "/etc/vault-agent.d/jwt-template.ctmpl"
  destination = "/etc/consul.d/token"
  command     = "sudo service consul reload"
}
vault {
  address = "$${VAULT_ADDR}"
}
EOF
cat <<EOF > /etc/systemd/system/vault-agent.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/vault agent -config=/etc/vault-agent.d/vault.hcl -log-level=debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
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

#envoy tgw
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -gateway=terminating -register -service "aws-us-east-1-terminating-gateway" -address "$${local_ipv4}:443" -token-file /etc/envoy/consul.token -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy.service
sudo systemctl start envoy.service

#start the vault-agent
sleep 30
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service

exit 0
