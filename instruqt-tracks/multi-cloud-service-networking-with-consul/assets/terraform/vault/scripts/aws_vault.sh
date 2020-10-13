#!/bin/bash

local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install vault & consul
sudo apt install jq vault-enterprise consul-enterprise -y
mkdir -p /opt/vault/raft
chown vault:vault /opt/vault/raft

#add the vault config
cat <<EOF> /etc/vault.d/vault.hcl
#UI
ui = true

#Storage
storage "raft" {
  path = "/opt/vault/raft"
  node_id = "vault-server-0"
}

# HTTP listener
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"
}

seal "awskms" {
  region = "us-east-1"
  kms_key_id = "${kms_key}"
}

api_addr     = "http://$${local_ipv4}:8200"
cluster_addr = "http://$${local_ipv4}:8201"
EOF

sudo systemctl enable vault.service
sudo systemctl start vault.service

#keep vault restarting for temp licensing
sudo crontab -l > vault
sudo echo "*/10 * * * * sudo service vault restart" >> vault
sudo crontab vault
sudo rm vault

exit 0
