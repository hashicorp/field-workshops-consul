#!/bin/bash

#wait for box
sleep 30

#utils
sudo apt install -y gnupg2

#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#add envoy package
curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list
sudo apt update
sudo apt install -y getenvoy-envoy

#install packages
sudo apt update -y
sudo apt install awscli consul-enterprise=1.11.2+ent jq unzip getenvoy-envoy -y

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
instance="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

#dirs
mkdir -p /opt/consul/tls/
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/

#fix things
sudo mkdir /etc/envoy
sudo echo ${token} > /etc/envoy/consul.token
sudo touch /etc/consul.d/consul.env

#consul
cat <<EOF> /opt/consul/tls/ca-cert.pem
${ca}
EOF

cat <<EOF> /etc/consul.d/consul.hcl
advertise_addr = "$${local_ipv4}"
client_addr = "0.0.0.0"
node_name = "$${instance}"
connect = {
  enabled = true
}
data_dir = "/opt/consul/data"
ports = {
  grpc = 8502
}
partition = "${partition}"
EOF

cat <<EOF> /etc/consul.d/hcp_config.hcl
${agent_config}
EOF

cat <<EOF> /etc/consul.d/acl.hcl
acl = {
  tokens = {
    default = "${token}"
  }
}
EOF

cat <<EOF> /etc/consul.d/tls.hcl
ca_file = "/opt/consul/tls/ca-cert.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
EOF

sudo systemctl enable consul.service
sudo systemctl start consul.service

# envoy mgw

cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -gateway=mesh -partition "${partition}" -register -service "mesh-gateway" -address "$${local_ipv4}:8443" -token-file /etc/envoy/consul.token -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable envoy.service
sudo systemctl start envoy.service

exit 0