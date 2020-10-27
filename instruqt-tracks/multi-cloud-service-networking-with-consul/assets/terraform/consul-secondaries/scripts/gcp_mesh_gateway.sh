#!/bin/bash

#metadata
local_ipv4=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
public_ipv4="$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)"

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install consul
sudo apt install consul-enterprise vault-enterprise -y

#get secrets
GCP_ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/zone | cut -d "/" -f4-)
GCP_SA=$(gcloud config get-value account)
export VAULT_ADDR="http://$(gcloud compute instances describe vault-server --zone $GCP_ZONE --format="value(networkInterfaces[0].networkIP)"):8200"
export VAULT_TOKEN=$(vault login -field=token -method=gcp \
  method="iam" \
  role="consul" \
  service_account="$${GCP_SA}")
AGENT_TOKEN=$(vault kv get -field=master_token kv/consul)
GOSSIP_KEY=$(vault kv get -field=gossip_key kv/consul)
CA_CERT=$(vault read -field certificate pki/cert/ca)

#config
cat <<EOF> /etc/consul.d/client.json
{
  "datacenter": "gcp-us-central-1",
  "primary_datacenter": "aws-us-east-1",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=gce tag_value=consul-${env}"],
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
    agent  = "$${AGENT_TOKEN}"
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

sudo systemctl enable consul.service
sudo systemctl start consul.service

sleep 30

#envoy mgw
curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.14.1
cp /root/.getenvoy/builds/standard/1.14.1/linux_glibc/bin/envoy /usr/local/bin/envoy

cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -expose-servers -gateway=mesh -register -service "mesh-gateway" -address "$${local_ipv4}:443" -wan-address "$${public_ipv4}:443" -token="$${AGENT_TOKEN}" -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable envoy.service
sudo systemctl start envoy.service

exit 0
