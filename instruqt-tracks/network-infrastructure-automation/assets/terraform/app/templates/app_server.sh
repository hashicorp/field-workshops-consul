#!/bin/bash

#packages
sudo apt update -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update -y
apt install consul=1.9.4 unzip -y

#config
cat << EOF > /etc/consul.d/consul.hcl
data_dir = "/opt/consul"
ui = true
retry_join = ["${consul_server_ip}"]
EOF

cat << EOF > /etc/consul.d/app.json
{
  "service": {
    "name": "app",
    "port": 9091,
    "checks": [
      {
        "id": "app",
        "name": "App TCP Check",
        "tcp": "localhost:9091",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status

#Install Dockers
sudo snap install docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sleep 10
cat << EOF > docker-compose.yml
version: "3.7"
services:
  app:
    image: nicholasjackson/fake-service:v0.7.8
    ports:
      - 9091:9091
    environment:
      LISTEN_ADDR: 0.0.0.0:9091
      NAME: app
      MESSAGE: "Hello, Monolith!"
      SERVER_TYPE: "http"

EOF
sudo docker-compose up -d
