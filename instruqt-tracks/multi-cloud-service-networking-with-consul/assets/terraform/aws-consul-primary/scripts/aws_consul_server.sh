#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PrivateIpAddress' \
 --output text):8200
vault login -method=aws role=consul
CONNECT_TOKEN=$(vault token create -field token -policy connect -period 8h -orphan)

#dirs
mkdir -p /etc/vault-agent.d/
mkdir -p /opt/consul/tls/
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/

#vault-agent
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}
{{ .Data.certificate }}
{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-cert-template.ctmpl
{{ with secret "pki/issue/consul" "common_name=consul-server-0.server.aws-us-east-1.consul" "alt_names=consul-server-0.server.aws-us-east-1.consul,server.aws-us-east-1.consul,localhost" "ip_sans=127.0.0.1" "key_usage=DigitalSignature,KeyEncipherment" "ext_key_usage=ServerAuth,ClientAuth" }}
{{ .Data.certificate }}
{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-key-template.ctmpl
{{ with secret "pki/issue/consul" "common_name=consul-server-0.server.aws-us-east-1.consul" "alt_names=consul-server-0.server.aws-us-east-1.consul,server.aws-us-east-1.consul,localhost" "ip_sans=127.0.0.1" "key_usage=DigitalSignature,KeyEncipherment" "ext_key_usage=ServerAuth,ClientAuth" }}
{{ .Data.private_key }}
{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-acl-template-bootstrap.ctmpl
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  tokens {
    master = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
    agent  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-acl-template.ctmpl
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  tokens {
    agent  = {{ with secret "consul/creds/agent" }}"{{ .Data.token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
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
  source      = "/etc/vault-agent.d/consul-cert-template.ctmpl"
  destination = "/opt/consul/tls/server-cert.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/consul-key-template.ctmpl"
  destination = "/opt/consul/tls/server-key.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul reload"
}
vault {
  address = "$${VAULT_ADDR}"
}
EOF
cat <<EOF> /etc/vault-agent.d/vault-bootstrap.hcl
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
  source      = "/etc/vault-agent.d/consul-cert-template.ctmpl"
  destination = "/opt/consul/tls/server-cert.pem"
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/consul-key-template.ctmpl"
  destination = "/opt/consul/tls/server-key.pem"
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template-bootstrap.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul restart"
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
sudo vault agent -config=/etc/vault-agent.d/vault-bootstrap.hcl -log-level=debug -exit-after-auth

#consul
cat <<EOF> /etc/consul.d/server.json
{
  "datacenter": "aws-us-east-1",
  "primary_datacenter": "aws-us-east-1",
  "server": true,
  "bootstrap_expect": 1,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "node_name": "consul-server-0",
  "ui": true,
  "license_path": "/etc/consul.d/consul.hclic",
  "auto_config": {
    "authorization": {
      "enabled": true,
      "static": {
        "oidc_discovery_url": "$${VAULT_ADDR}/v1/identity/oidc",
        "bound_issuer": "$${VAULT_ADDR}/v1/identity/oidc",
        "bound_audiences": [
          "consul-server-aws-us-east-1"
        ],
        "claim_mappings": {
          "/consul/node_arn": "node"
        },
        "claim_assertions": [
          "value.node matches \"^arn:aws:sts::(.*?):assumed-role/(.*?)/\$${node}\$\""
        ]
      }
    }
  },
  "connect": {
    "enable_mesh_gateway_wan_federation": true,
    "enabled": true,
    "ca_provider": "vault",
    "ca_config": {
      "address": "$${VAULT_ADDR}",
      "token": "$${CONNECT_TOKEN}",
      "root_pki_path": "connect-root/",
      "intermediate_pki_path": "connect-intermediate-east/"
    }
  }
}
EOF
cat <<EOF> /etc/consul.d/tls.json
{
  "verify_incoming_rpc": true,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ca_file": "/opt/consul/tls/ca-cert.pem",
  "cert_file": "/opt/consul/tls/server-cert.pem",
  "key_file": "/opt/consul/tls/server-key.pem",
  "auto_encrypt": {
    "allow_tls": true
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
