#!/bin/bash

#metadata
local_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")"
public_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")"

#vault
az login --identity
export VAULT_ADDR="http://$(az vm show -g $(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .resourceGroupName') -n vault-server-vm -d | jq -r .privateIps):8200"

#dirs
mkdir -p /etc/vault-agent.d/
mkdir -p /opt/consul/tls/
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/

#vault-agent
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-acl-template.ctmpl
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  enable_token_replication = true
  tokens {
    agent  = {{ with secret "consul/creds/agent" }}"{{ .Data.token }}"{{ end }}
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
  method "azure" {
      mount_path = "auth/azure"
      config = {
          role = "consul"
          resource = "https://management.azure.com/"
      }
  }
}
template {
  source      = "/etc/vault-agent.d/consul-ca-template.ctmpl"
  destination = "/opt/consul/tls/ca-cert.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul reload"
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
sudo vault agent -config=/etc/vault-agent.d/vault.hcl -log-level=debug -exit-after-auth

#consul
cat <<EOF> /etc/consul.d/consul.hcl
datacenter = "azure-west-us-2"
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
retry_join = ["provider=azure tag_name=Env tag_value=consul-${env} subscription_id=${subscription_id}"]
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
sudo systemctl enable consul.service
sudo systemctl start consul.service

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

#start the vault-agent
sleep 30
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service

exit 0
