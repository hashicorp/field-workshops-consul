#!/bin/bash

#meta
local_ipv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
instance="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

#dirs
mkdir -p /opt/vault/raft
mkdir -p /etc/vault-agent.d/
mkdir -p /opt/consul/tls/
chown -R vault:vault /opt/vault/raft
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/

#vault
cat <<EOF> /etc/vault.d/vault.hcl
ui = true
license_path = "/etc/vault.d/vault.hclic"

storage "raft" {
  path = "/opt/vault/raft"
  node_id = "vault-server-0"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"
}

seal "awskms" {
  region = "us-east-1"
  kms_key_id = "${kms_key}"
}

api_addr     = "http://$${local_ipv4}:8200"
cluster_addr = "http://$${local_ipv4}:8201"
EOF
cat <<'EOF'> /usr/lib/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable vault.service
sudo systemctl start vault.service

#vault agent
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/vault-template.ctmpl
service_registration "consul" {
  address = "localhost:8500"{{ with secret "consul/creds/vault" }}
  token   = "{{ .Data.token }}"{{ end }}
}
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
          role = "vault"
      }
  }
}
template {
  source      = "/etc/vault-agent.d/consul-ca-template.ctmpl"
  destination = "/opt/consul/tls/ca-cert.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/vault-template.ctmpl"
  destination = "/etc/vault.d/consul.hcl"
  command     = "sudo service vault restart"
}
template {
  source      = "/etc/vault-agent.d/jwt-template.ctmpl"
  destination = "/etc/consul.d/token"
  command     = "sudo service consul reload"
}
vault {
  address = "http://localhost:8200"
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
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "aws-us-east-1",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "node_name": "$${instance}",
  "log_level": "INFO",
  "ui": true,
  "connect": {
    "enabled": true
  },
  "ports": {
    "grpc": 8502
  }
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

#start the vault-agent
sleep 30
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service

exit 0
