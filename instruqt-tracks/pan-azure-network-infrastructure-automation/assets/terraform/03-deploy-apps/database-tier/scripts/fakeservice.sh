#!/bin/bash
# local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
PRIVATE_IP="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2019-06-04&format=text")"
PUBLIC_IP="$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2019-06-04&format=text")"

#Utils
sudo apt-get install -y unzip
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y jq


#Download Consul
CONSUL_VERSION="1.16.3"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

sudo mkdir --parents /opt/consul

#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl


cat << EOF > /etc/consul.d/consul.hcl
data_dir = "/opt/consul"
datacenter = "AcademyDC1"
advertise_addr = "$PRIVATE_IP"
ui = true
retry_join = ["${consul_server_ip}"]
EOF

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



cat << EOF > /etc/consul.d/fakeservice.hcl
service {
  id      = "db"
  name    = "db"
  tags    = ["db"]
  port    = 9095
  check {
    id       = "db"
    name     = "TCP on port 9095"
    tcp      = "localhost:9095"
    interval = "10s"
    timeout  = "1s"
  }
}
EOF



#Enable the service
sudo systemctl enable consul
# In case of not known update
sudo systemctl daemon-reload
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

  database:
    image: nicholasjackson/fake-service:v0.7.8
    environment:
      LISTEN_ADDR: 0.0.0.0:9095
      MESSAGE: "database response"
      NAME: "database"
      SERVER_TYPE: "http"
      HTTP_CLIENT_APPEND_REQUEST: "true"
    ports:
    - "9095:9095"



EOF
sudo docker-compose up -d


sleep 30
nc -w0 -u 10.2.0.5 5140 <<< '<165>1 2016-01-01T12:08:21Z hostname db 1234 ID47 [exampleSDID@32473 iut="9" eventSource="test" eventID="123"] The following is db of local log'