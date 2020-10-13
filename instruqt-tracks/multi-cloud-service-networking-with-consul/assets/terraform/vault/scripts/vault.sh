#!/bin/bash

#update packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y

#install vault
sudo apt install vault-enterprise -y

#add the vault config
cat <<EOF> /etc/vault.d/vault.hcl
#UI
ui = true

#Storage
storage "file" {
  path = "/opt/vault/data"
}

# HTTPS listener
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}

seal "awskms" {
  region = "us-east-1"
  kms_key_id = "d7c1ffd9-8cce-45e7-be4a-bb38dd205966"
}
EOF

sudo systemctl enable vault.service
sudo systemctl start vault.service

#keep vault restarting for temp licensing
sudo crontab -l > vault
sudo echo "*/10 * * * * sudo service vault restart" >> vault
sudo crontab vault
sudo rm vault

exit 0
