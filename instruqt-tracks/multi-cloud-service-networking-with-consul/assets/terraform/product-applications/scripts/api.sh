#!/bin/bash

#metadata
local_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")"
public_ipv4="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")"

#update & install packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt update -y
sudo apt install azure-cli consul-enterprise vault-enterprise jq -y

#get secrets
az login --identity
export VAULT_ADDR="http://$(az vm show -g $(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .resourceGroupName') -n vault-server-vm -d | jq -r .privateIps):8200"
export VAULT_TOKEN=$(vault write -field=token auth/azure/login -field=token role="product-api" \
     jwt="$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true | jq -r '.access_token')")
AGENT_TOKEN=$(vault kv get -field=master_token kv/consul)
GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
CA_CERT=$(vault read -field certificate pki/cert/ca)

#consul client config
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "azure-west-us-2",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=azure tag_name=Env tag_value=consul-${env} subscription_id=${subscription_id}"],
  "ui": true,
  "connect": {
    "enabled": true
  },
  "ports": {
    "grpc": 8502
  }
}
EOF

cat <<EOF> /etc/consul.d/secrets.hcl
acl {
  enabled        = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    default  = "$${AGENT_TOKEN}"
  }
}
encrypt = "$${GOSSIP_KEY}"
EOF


mkdir -p /opt/consul/tls/
echo "$${CA_CERT}" > /opt/consul/tls/ca-cert.pem

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

#app config
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

sudo systemctl enable consul.service
sudo systemctl start consul.service

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
ExecStart=/usr/bin/consul connect envoy -namespace product -sidecar-for product-api -envoy-binary /usr/local/bin/envoy -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
Environment="CONSUL_HTTP_TOKEN=$${AGENT_TOKEN}"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable envoy.service
sudo systemctl start envoy.service

#install the application
wget https://github.com/hashicorp-demoapp/product-api-go/releases/download/v0.0.12/product-api -O /product-api
chmod +x /product-api

#application configuration
cat <<EOF > /conf.json
{
  "db_connection": "host=localhost port=5432 user=postgres@${env} password=${postgres_password} dbname=postgres sslmode=disable",
  "bind_address": ":9090"
}
EOF

# Setup Product API in SystemD
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

exit 0
