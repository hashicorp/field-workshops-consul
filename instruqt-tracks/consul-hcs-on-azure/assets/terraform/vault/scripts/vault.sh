#!/bin/bash

apt-get update -y
apt-get install -y docker.io
snap install vault

curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

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
