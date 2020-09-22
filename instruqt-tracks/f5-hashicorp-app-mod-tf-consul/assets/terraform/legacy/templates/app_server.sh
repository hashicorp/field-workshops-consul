#!/bin/bash

#Utils
apt-get update -y
apt-get upgrade -y
sudo apt-get install -y unzip jq

service_id=$(hostname)
hostname=$(hostname)

#get the jwt from azure msi
jwt="$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true | jq -r '.access_token')"

#log into vault
token=$(curl -s \
    --request POST \
    --data '{"role": "app", "jwt": "'$jwt'"}' \
    http://${vault_server}:8200/v1/auth/azure/login | jq -r '.auth.client_token')

#get the consul secret
consul_secret=$(curl -s \
    --header "X-Vault-Token: $token" \
    http://${vault_server}:8200/v1/secret/data/consul/shared | jq '.data.data')

#extract the bootstrap info
gossip_key=$(echo $consul_secret | jq -r .gossip_key)
retry_join=$(echo $consul_secret | jq -r .retry_join)
ca=$(echo $consul_secret | jq -r .ca)

#debug
echo $gossip_key
echo $retry_join
echo "$ca"

# Install Consul
cd /tmp
wget https://releases.hashicorp.com/consul/1.8.0+ent/consul_1.8.0+ent_linux_amd64.zip -O consul.zip
unzip ./consul.zip
mv ./consul /usr/bin/consul

mkdir -p /etc/consul/config

cat <<EOF > /etc/consul/ca.pem
"$ca"
EOF

cat <<EOF > /etc/consul/config/app.hcl
service {
  name = "app"
  id = "app-$(hostname)"
  port = 9091
  connect {
    sidecar_service {}
  }
}
EOF

# Generate the consul startup script
#!/bin/sh -e
cat <<EOF > /etc/consul/consul_start.sh
#!/bin/bash -e

# Get JWT token from the metadata service and write it to a file
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s | jq -r .access_token > ./meta.token

# Use the token to log into the Consul server, we need a valid ACL token to join the cluster and setup autoencrypt
CONSUL_HTTP_ADDR=https://$retry_join consul login -method azure -bearer-token-file ./meta.token -token-sink-file /etc/consul/consul.token

# Generate the Consul Config which includes the token so Consul can join the cluster
cat <<EOC > /etc/consul/config/consul.json
{
  "acl":{
   "enabled":true,
    "down_policy":"async-cache",
    "default_policy":"deny",
    "tokens": {
      "default":"\$(cat /etc/consul/consul.token)"
    }
  },
  "ca_file":"/etc/consul/ca.pem",
  "verify_outgoing":true,
  "datacenter":"${consul_datacenter}",
  "encrypt":"$gossip_key",
  "server":false,
  "log_level":"INFO",
  "ui":true,
  "retry_join":[
    "$retry_join"
  ],
  "ports": {
    "grpc": 8502
  },
  "auto_encrypt":{
    "tls":true
  }
}
EOC

# Run Consul
/usr/bin/consul agent -node=$(hostname) -config-dir=/etc/consul/config/ -data-dir=/etc/consul/data
EOF

chmod +x /etc/consul/consul_start.sh

# Setup Consul agent in SystemD
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Agent
After=network-online.target

[Service]
WorkingDirectory=/etc/consul
ExecStart=/etc/consul/consul_start.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Install Envoy
curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.12.6
cp /root/.getenvoy/builds/standard/1.12.6/linux_glibc/bin/envoy /usr/bin/envoy

# Setup Envoy Service in SystemD
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for app-$(hostname) -envoy-binary /usr/bin/envoy -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
Environment="CONSUL_HTTP_TOKEN_FILE=/etc/consul/consul.token"

[Install]
WantedBy=multi-user.target
EOF

# Install Fake Service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.14.1/fake-service-linux -O fake-service
mv ./fake-service /usr/bin/fake-service
chmod +x /usr/bin/fake-service

# Setup Fake Service in SystemD
cat <<EOF > /etc/systemd/system/fake-service.service
[Unit]
Description=App Service
After=network-online.target

[Service]
ExecStart=/usr/bin/fake-service
Restart=always
RestartSec=5
StartLimitIntervalSec=0
Environment="LISTEN_ADDR=0.0.0.0:9091"
Environment="NAME=app"
Environment="MESSAGE=Hello, Monolith!"
Environment="SERVER_TYPE=http"

[Install]
WantedBy=multi-user.target
EOF

# Restart SystemD
systemctl daemon-reload

systemctl enable consul
systemctl enable envoy
systemctl enable fake-service

systemctl restart consul
systemctl restart envoy
systemctl restart fake-service
