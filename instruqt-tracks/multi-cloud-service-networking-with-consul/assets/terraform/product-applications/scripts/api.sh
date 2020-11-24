#!/bin/bash

#metadata
local_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")"
public_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")"

#update & install packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y
sudo apt install consul-enterprise vault-enterprise jq -y

#azure cli
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo apt-key add -
AZ_REPO=$(lsb_release -cs)
sudo apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main"
sudo apt update -y
sudo apt install azure-cli -y

#vault
az login --identity
export VAULT_ADDR="http://$(az vm show -g $(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .resourceGroupName') -n vault-server-vm -d | jq -r .privateIps):8200"
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
  enable_token_replication = true
  tokens {
    agent  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
    default  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
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
  command     = "sudo service consul restart"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul restart"
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
sleep 10

#consul
mkdir -p /opt/consul/tls/
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
cat <<EOF > /etc/consul.d/product-api.hcl
service {
  name = "product-api"
  id = "product-api"
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
          }
        ]
      }
    }
  }
}
EOF
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10

#install envoy
curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.14.1
cp /root/.getenvoy/builds/standard/1.14.1/linux_glibc/bin/envoy /usr/local/bin/envoy
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -namespace product -sidecar-for product-api -envoy-binary /usr/local/bin/envoy -token-file /etc/envoy/consul.token -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy.service
sudo systemctl start envoy.service
sleep 5

#install the application
wget https://github.com/hashicorp-demoapp/product-api-go/releases/download/v0.0.12/product-api -O /product-api
chmod +x /product-api
cat <<EOF > /conf.json
{
  "db_connection": "host=localhost port=5432 user=postgres@${env} password=${postgres_password} dbname=postgres sslmode=disable",
  "bind_address": ":9090"
}
EOF
cat <<EOF > /etc/systemd/system/product-api.service
[Unit]
Description=Product API Service
After=network-online.target
[Service]
ExecStart=/product-api
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable product-api.service
sudo systemctl start product-api.service
sleep 5

#license
sudo crontab -l > consul
sudo echo "*/28 * * * * sudo service consul restart" >> consul
sudo crontab consul
sudo rm consul

#make sure the config was picked up
sudo service consul restart
sudo service envoy restart
sudo service product-api restart

exit 0
