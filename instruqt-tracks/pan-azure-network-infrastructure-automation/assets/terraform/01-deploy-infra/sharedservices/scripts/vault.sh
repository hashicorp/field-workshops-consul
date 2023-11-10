#!/bin/bash
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

apt-get update -y
# apt-get install -y docker.io
snap install vault

# curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

#Install Dockers
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

sudo apt install -y docker-compose

cat << EOF > /etc/profile.d/vault.sh
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
EOF

cat <<-EOF > /docker-compose.yml
version: '3'
services:
  vault:
    container_name: vault
    network_mode: host
    restart: always
    image: hashicorp/vault
    environment:
      - VAULT_DEV_ROOT_TOKEN_ID=root
    ports:
      - "8200:8200"
EOF

/usr/local/bin/docker-compose up -d


