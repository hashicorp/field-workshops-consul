#!/bin/bash

#Get IP
#local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#Utils
sudo apt-get install unzip

#Download Consul
CONSUL_VERSION="1.7.2"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

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
datacenter = "dc1"
data_dir = "/opt/consul"
ui = true
EOF

cat << EOF > /etc/consul.d/client.hcl
retry_join = ["10.1.1.100"]
EOF

cat << EOF > /etc/consul.d/nginx.json
{
  "service": {
    "name": "nginx",
    "port": 80,
    "checks": [
      {
        "id": "nginx",
        "name": "nginx TCP Check",
        "tcp": "localhost:80",
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


# create consul template for nginx config
cat << EOF > /etc/nginx/conf.d/load-balancer.conf.ctmpl
upstream app {
{{ range service "app" }}
  server {{ .Address }}:{{ .Port }};
{{ end }}
}
server {
    listen       9091;
    server_name  localhost;
    
    location / {
       proxy_pass http://api;
    }
}
EOF

# create consul-template Config
cat << EOF > /etc/consul-template/consul-template-config.hcl
template {
source      = "/etc/nginx/conf.d/load-balancer.conf.ctmpl"
destination = "/etc/nginx/conf.d/default.conf"
command = "docker-compose -f /home/ubuntu/docker-compose.yml restart"
}
EOF
#Install Dockers
sudo snap install docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Run  nginx
sleep 10
cat << EOF > docker-compose.yml
version: "3.7"
services:
  web:
    image: nginxdemos/hello
    ports:
    - "80:80"
    restart: always
    command: [nginx-debug, '-g', 'daemon off;']
    network_mode: "host"
EOF
sudo docker-compose up -d