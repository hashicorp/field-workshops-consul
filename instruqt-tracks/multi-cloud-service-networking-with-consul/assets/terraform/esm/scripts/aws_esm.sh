#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

#vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PrivateIpAddress' \
 --output text):8200
mkdir -p /etc/vault-agent.d/
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-acl-template.ctmpl
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  tokens {
    agent  = {{ with secret "consul/creds/esm" }}"{{ .Data.token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/esm-token-template.ctmpl
token = {{ with secret "consul/creds/esm" }}"{{ .Data.token }}"{{ end }}
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
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/esm-token-template.ctmpl"
  destination = "/etc/consul-esm.d/config.hcl"
  command     = "sudo service consul-esm restart"
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
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service
sleep 10

#consul
mkdir -p /opt/consul/tls/
cat <<EOF> /etc/consul.d/consul.hcl
datacenter = "aws-us-east-1"
primary_datacenter = "aws-us-east-1"
advertise_addr = "$${local_ipv4}"
client_addr = "0.0.0.0"
ui = true
connect = {
  enabled = true
}
data_dir = "/opt/consul/data"
log_level = "INFO"
ports = {
  grpc = 8502
}
retry_join = ["provider=aws tag_key=Env tag_value=consul-${env}"]
EOF
cat <<EOF> /etc/consul.d/tls.hcl
ca_file = "/opt/consul/tls/ca-cert.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  tls = true
}
EOF
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10

#esm
curl -s -O https://releases.hashicorp.com/consul-esm/0.4.0/consul-esm_0.4.0_linux_amd64.tgz
tar -xvzf consul-esm*
mv consul-esm /usr/local/bin/consul-esm
rm -f *.tgz

mkdir -p /etc/consul-esm.d/
cat <<EOF> /usr/lib/systemd/system/consul-esm.service
[Unit]
Description=Consul ESM
Documentation=https://github.com/hashicorp/consul-esm

Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul-esm -config-dir /etc/consul-esm.d/
KillMode=process
Restart=on-failure
RestartSec=2

PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_net_raw=+ep' /usr/local/bin/consul-esm

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable consul-esm.service
sudo systemctl start consul-esm.service
sleep 10

#make sure the config was picked up
sudo service consul restart
sudo service consul-esm restart

exit 0
