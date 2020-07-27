#!/bin/bash -e

apt-get update -y
apt-get upgrade -y
apt-get install -y unzip jq

# Install Consul 
cd /tmp
wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip -O consul.zip
unzip ./consul.zip
mv ./consul /usr/bin/consul

mkdir -p /etc/consul/config

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

# Generate the consul startup script
#!/bin/sh -e

cat <<EOF > /etc/consul/consul_start.sh
#!/bin/bash -e

# Get JWT token from the metadata service and write it to a file
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s | jq -r .access_token > ./meta.token

# Use the token to log into the Consul server, we need a valid ACL token to join the cluster and setup autoencrypt
CONSUL_HTTP_ADDR=https://${consul_join_addr} consul login -method my-jwt -bearer-token-file ./meta.token -token-sink-file /etc/consul/consul.token

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
  "encrypt":"${consul_gossip_key}",
  "server":false,
  "log_level":"INFO",
  "ui":true,
  "retry_join":[
    "${consul_join_addr}"
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
/usr/bin/consul agent -node=payments -config-dir=/etc/consul/config/ -data-dir=/etc/consul/data
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
ExecStart=/usr/bin/consul connect envoy -sidecar-for payments-1 -envoy-binary /usr/bin/envoy -- -l debug
Restart=always
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
Description=Payment Service
After=network-online.target

[Service]
ExecStart=/usr/bin/fake-service
Restart=always
Environment="LISTEN_ADDR=127.0.0.1:9090"
Environment="NAME=Payments-VM"
Environment="MESSAGE=Hello from API"

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