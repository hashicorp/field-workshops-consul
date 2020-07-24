#!/bin/bash -e

apt-get update -y
apt-get upgrade -y
apt-get install unzip jq

# Install Consul 
cd /tmp
wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip -O consul.zip
unzip ./consul.zip
mv ./consul /usr/bin/consul

mkdir -p /etc/consul/config

# Add the Consul config
cat <<EOF > /etc/consul/config/config.json
${config}
EOF

cat <<EOF > /etc/consul/ca.pem
${ca}
EOF

cat <<EOF > /etc/consul/config/payments.hcl
service {
  name = "payments"
  id = "payments-1"
  port = 9090

  connect { 
    sidecar_service {
      proxy {
      }
    }
  }
}
EOF

# Setup Consul agent in SystemD
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Agent

[Service]
WorkingDirectory=/etc/consul
ExecStart="/usr/bin/consul agent -node=vm -config-file=/etc/consul/config/config.json -data-dir=/etc/consul/data"
Environment="CONSUL_CACERT=/etc/consul/ca.pem"

[Install]
WantedBy=network-online.target
EOF

# Install Fake Service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.14.1/fake-service-linux -O fake-service
mv ./fake-service /usr/bin/fake-service

# Setup Fake Service in SystemD
cat <<EOF > /etc/systemd/system/fake-service.service
[Unit]
Description=Payment Service

[Service]
ExecStart="/usr/bin/fake-service"
Environment="LISTEN_ADDR=127.0.0.1:9090"
Environment="NAME=Payments-VM"
Environment="MESSAGE=Hello from API"

[Install]
WantedBy=network-online.target
EOF

# Install Envoy
curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.12.6
cp /root/.getenvoy/builds/standard/1.12.6/linux_glibc/bin/envoy /usr/bin/envoy

# Setup Envoy Service in SystemD
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy

[Service]
ExecStart="/usr/bin/consul connect envoy -sidecar-for payments-1 -envoy-binary /usr/bin/envoy -- -l debug"
Environment="CONSUL_CACERT=/etc/consul/ca.pem"
Environment="CONSUL_HTTP_TOKEN_FILE=/etc/consul/acl.token"

[Install]
WantedBy=network-online.target
EOF

# Restart SystemD
systemctl daemon-reload
systemctl restart consul
systemctl restart fake-service
systemctl restart envoy