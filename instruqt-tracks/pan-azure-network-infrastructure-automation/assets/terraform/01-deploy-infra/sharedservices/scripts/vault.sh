#!/bin/bash
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

apt-get update -y
apt-get install -y docker.io
snap install vault

curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

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
    image: vault
    environment:
      - VAULT_DEV_ROOT_TOKEN_ID=root
EOF

/usr/local/bin/docker-compose up -d


