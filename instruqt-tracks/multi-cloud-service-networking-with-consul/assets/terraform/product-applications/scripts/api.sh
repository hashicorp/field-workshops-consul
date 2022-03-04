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
cat <<EOF> /etc/vault-agent.d/product-api-template.ctmpl
service {
  name = "product-api"
  id = "product-api"
  token = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
  namespace = "product"
  port = 9090
  check = {
    http = "http://localhost:9090/health"
    interval = "5s"
    method = "GET"
    name = "http health check"
    timeout = "2s"
  }
  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "postgres"
            destination_namespace = "default"
            local_bind_port  = 5432
          },
          {
            destination_name = "jaeger-http-collector"
            destination_namespace = "default"
            datacenter = "aws-us-east-1"
            local_bind_port  = 14268
          },
          {
            destination_name = "zipkin-http-collector"
            destination_namespace = "default"
            datacenter = "aws-us-east-1"
            local_bind_port  = 9411
          }
        ]
      }
    }
  }
}
EOF
cat <<EOF> /etc/vault-agent.d/envoy-token-template.ctmpl
{{ with secret "kv/consul" }}{{ .Data.data.master_token }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/vault.hcl
pid_file = "/var/run/vault-agent-pidfile"
auto_auth {
  method "azure" {
      mount_path = "auth/azure"
      config = {
          role = "product-api"
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
  source      = "/etc/vault-agent.d/product-api-template.ctmpl"
  destination = "/etc/consul.d/product-api.hcl"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/envoy-token-template.ctmpl"
  destination = "/etc/envoy/consul.token"
  command     = "sudo service envoy restart"
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

#install envoy
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -namespace product -sidecar-for product-api -envoy-binary /usr/bin/envoy -token-file /etc/envoy/consul.token -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy.service
sudo systemctl start envoy.service

#install the application
wget https://github.com/hashicorp-demoapp/product-api-go/releases/download/v0.0.20/product_api_go_linux_amd64.zip -O product_api_go_linux_amd64.zip
unzip product_api_go_linux_amd64.zip
chmod +x /product-api
cat <<EOF > /conf.json
{
  "db_connection": "host=127.0.0.1 port=5432 user=postgres password=${postgres_password} dbname=postgres sslmode=require",
  "bind_address": ":9090"
}
EOF

#run it
cat <<EOF > /etc/systemd/system/product-api.service
[Unit]
Description=Product API Service
After=network-online.target
[Service]
ExecStart=/product-api
Environment=JAEGER_ENDPOINT=http://127.0.0.1:14268/api/traces
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable product-api.service
sudo systemctl start product-api.service

#start the vault-agent
sleep 30
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service

exit 0
