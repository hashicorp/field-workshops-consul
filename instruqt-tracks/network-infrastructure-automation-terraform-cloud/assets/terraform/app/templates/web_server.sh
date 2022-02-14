#!/bin/bash

#packages
sudo apt update -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update -y
apt install consul=1.9.4 unzip nginx -y

#cts
CONSUL_TEMPLATE_VERSION="0.22.0"
sudo curl --silent --remote-name https://releases.hashicorp.com/consul-template/$${CONSUL_TEMPLATE_VERSION}/consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
sudo unzip consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
sudo mv consul-template /usr/local/bin/consul-template
sudo cat << EOF > /etc/systemd/system/consul-template.service
[Unit]
Description="Template rendering, notifier, and supervisor for @hashicorp Consul and Vault data."
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
[Service]
User=root
Group=root
ExecStart=/usr/local/bin/consul-template -log-level=debug -config=/etc/consul-template/consul-template-config.hcl
ExecReload=/usr/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#consul-template
sudo mkdir --parents /etc/consul-template
sudo touch /etc/consul-template/consul-template-config.hcl
sudo chmod 640 /etc/consul-template/consul-template-config.hcl

#config
cat << EOF > /etc/consul.d/consul.hcl
data_dir = "/opt/consul"
ui = true
retry_join = ["${consul_server_ip}"]
EOF

cat << EOF > /etc/consul.d/nginx.json
{
  "service": {
    "name": "web",
    "port": 9090,
    "meta":
      {
        "AS3TMPL": "http",
        "VSIP": "${vip_internal_address}",
        "VSPORT": "80"
      },
    "checks": [
      {
        "id": "web",
        "name": "web TCP Check",
        "tcp": "localhost:9090",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

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
       proxy_pass http://app;
    }
}
EOF

cat << EOF > /etc/consul-template/consul-template-config.hcl
template {
source      = "/etc/nginx/conf.d/load-balancer.conf.ctmpl"
destination = "/etc/nginx/conf.d/default.conf"
command = "service nginx reload"
}
EOF

#Enable the services
sudo systemctl enable consul
sudo systemctl enable nginx
sudo service nginx start
sudo service consul start
sudo service consul status
sudo systemctl enable consul-template
sudo service consul-template start
sudo service consul-template status

#Install Dockers
sudo snap install docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sleep 10
cat << EOF > docker-compose.yml
version: "3.7"
services:
  web:
    image: nicholasjackson/fake-service:v0.7.8
    network_mode: "host"
    environment:
      LISTEN_ADDR: 0.0.0.0:9090
      NAME: web
      MESSAGE: "Hello, Web!"
      SERVER_TYPE: "http"
      UPSTREAM_URIS: "http://localhost:9091"

EOF
sudo docker-compose up -d
