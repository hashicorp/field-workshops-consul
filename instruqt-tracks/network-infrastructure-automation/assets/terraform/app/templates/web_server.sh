#!/bin/bash

#Get IP
#local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#Utils
sudo apt-get install -y unzip nginx

#Download Consul
CONSUL_TEMPLATE_VERSION="0.22.0"
CONSUL_VERSION="1.8.0+ent"
curl --silent --remote-name https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip
curl --silent --remote-name https://releases.hashicorp.com/consul-template/$${CONSUL_TEMPLATE_VERSION}/consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_$${CONSUL_VERSION}_linux_amd64.zip
unzip consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo chown root:root consul consul-template
sudo mv consul* /usr/local/bin/
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

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -bind '{{ GetInterfaceIP "eth0" }}' -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo cat << EOF > /etc/systemd/system/consul-template.service
[Unit]
Description="Template rendering, notifier, and supervisor for @hashicorp Consul and Vault data."
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
[Service]
User=root
Group=root
ExecStart=/usr/local/bin/consul-template -config=/etc/consul-template/consul-template-config.hcl
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Create config dirs
sudo mkdir --parents /etc/consul.d
sudo mkdir --parents /etc/nginx/conf.d
sudo mkdir --parents /etc/consul-template

sudo touch /etc/consul.d/consul.hcl
sudo touch /etc/consul-template/consul-template-config.hcl

sudo chown --recursive consul:consul /etc/consul.d
sudo chown --recursive consul:consul /etc/consul-template
sudo chmod 640 /etc/consul.d/consul.hcl
sudo chmod 640 /etc/consul-template/consul-template-config.hcl

cat << EOF > /etc/consul.d/ca.pem
${ca_cert}
EOF

cat << EOF > /etc/consul.d/hcs.json
${consulconfig}
EOF

cat << EOF > /etc/consul.d/zz_override.hcl
data_dir = "/opt/consul"
ui = true
ca_file = "/etc/consul.d/ca.pem"
acl = {
  tokens = {
    default = "${consul_token}"
  }
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
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

#Enable the service
sudo systemctl enable consul
sudo systemctl enable nginx

sudo service nginx start
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
       proxy_pass http://app;
    }
}
EOF

# create consul-template Config
cat << EOF > /etc/consul-template/consul-template-config.hcl
template {
source      = "/etc/nginx/conf.d/load-balancer.conf.ctmpl"
destination = "/etc/nginx/conf.d/default.conf"
command = "service nginx reload"
}
EOF

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
