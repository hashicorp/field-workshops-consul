#!/bin/bash

#ip
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#install vault & consul
mkdir -p /opt/vault/raft
chown vault:vault /opt/vault/raft

#consul
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "aws-us-east-1",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=aws tag_key=Env tag_value=consul-${env}"],
  "ui": true,
  "connect": {
    "enabled": true
  },
  "ports": {
    "grpc": 8502
  }
}
EOF

mkdir -p /opt/consul/tls/
cat <<EOF> /etc/consul.d/tls.json
{
  "verify_incoming": false,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ca_file": "/opt/consul/tls/ca-cert.pem",
  "auto_encrypt": {
    "tls": true
  }
}
EOF

sudo systemctl enable consul.service
sudo systemctl start consul.service

#vault
mkdir -p /opt/vault/raft
chown vault:vault /opt/vault/raft
cat <<EOF> /etc/vault.d/vault.hcl
ui = true

#Storage
storage "raft" {
  path = "/opt/vault/raft"
  node_id = "vault-server-0"
}

# HTTP listener
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
mkdir -p /etc/vault-agent.d/

cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}
{{ .Data.certificate }}
{{ end }}
EOF

cat <<EOF> /etc/vault-agent.d/consul-secrets-template.ctmpl
acl {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  tokens {
    agent  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
    default  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
EOF

cat <<EOF> /etc/vault-agent.d/vault-template.ctmpl
service_registration "consul" {
  address = "localhost:8500"{{ with secret "kv/consul" }}
  token   = "{{ .Data.data.master_token }}"{{ end }}
}
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
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/consul-secrets-template.ctmpl"
  destination = "/etc/consul.d/secrets.hcl"
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/vault-template.ctmpl"
  destination = "/etc/vault.d/consul.hcl"
  command     = "sudo service vault restart"
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

sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service

#keep vault restarting for temp licensing
sudo crontab -l > vault
sudo echo "*/28 * * * * sudo service vault restart" >> vault
sudo crontab vault
sudo rm vault

#license
sudo crontab -l > consul
sudo echo "*/28 * * * * sudo service consul restart" >> consul
sudo crontab consul
sudo rm consul

exit 0
