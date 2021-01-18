#!/bin/bash

#metadata
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#vault
export VAULT_ADDR=http://$(aws ec2 describe-instances --filters "Name=tag:Name,Values=vault" \
 --region us-east-1 --query 'Reservations[*].Instances[*].PrivateIpAddress' \
 --output text):8200
mkdir -p /etc/vault-agent.d/
cat <<EOF> /etc/vault-agent.d/consul-ca-template.ctmpl
{{ with secret "pki/cert/ca" }}{{ .Data.certificate }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/consul-acl-template.ctmpl
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  tokens {
    agent  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
    default  = {{ with secret "kv/consul" }}"{{ .Data.data.master_token }}"{{ end }}
  }
}
encrypt = {{ with secret "kv/consul" }}"{{ .Data.data.gossip_key }}"{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/envoy-token-template.ctmpl
{{ with secret "kv/consul" }}{{ .Data.data.master_token }}{{ end }}
EOF
cat <<EOF> /etc/vault-agent.d/vault.hcl
pid_file = "/var/run/vault-agent-pidfile"
auto_auth {
  method "aws" {
      mount_path = "auth/aws"
      config = {
          type = "iam"
          role = "consul"
      }
  }
}
template {
  source      = "/etc/vault-agent.d/consul-ca-template.ctmpl"
  destination = "/opt/consul/tls/ca-cert.pem"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/consul-acl-template.ctmpl"
  destination = "/etc/consul.d/acl.hcl"
  command     = "sudo service consul reload"
}
template {
  source      = "/etc/vault-agent.d/envoy-token-template.ctmpl"
  destination = "/etc/envoy/consul.token"
  command     = "sudo service envoy restart"
}
vault {
  address = "$${VAULT_ADDR}"
}
EOF
cat <<EOF > /etc/systemd/system/vault-agent.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/vault agent -config=/etc/vault-agent.d/vault.hcl -log-level=debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable vault-agent.service
sudo systemctl start vault-agent.service
sleep 10

#consul
mkdir -p /opt/consul/tls/
cat <<EOF> /etc/consul.d/consul.hcl
datacenter = "aws-us-east-1"
primary_datacenter = "aws-us-east-1"
advertise_addr = "$${local_ipv4}"
client_addr = "0.0.0.0"
connect = {
  enabled = true
}
data_dir = "/opt/consul/data"
log_level = "INFO"
ports = {
  grpc = 8502
}
retry_join = ["provider=aws tag_key=Env tag_value=consul-${env}"]
EOF
cat <<EOF> /etc/consul.d/tls.hcl
ca_file = "/opt/consul/tls/ca-cert.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  tls = true
}
EOF
cat <<-EOF > /etc/consul.d/jaeger-ui.json
{
  "service": {
    "name": "jaeger-ui",
    "port": 16686,
    "tags": [
      "monitoring"
    ],
    "check": {
      "id": "jaeger-ui",
      "name": "Jaeger UI TCP on port 16686",
      "tcp": "localhost:16686",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF
cat <<-EOF > /etc/consul.d/jaeger-http-collector.json
{
  "service": {
    "name": "jaeger-http-collector",
    "port": 14268,
    "tags": [
      "monitoring"
    ],
    "connect": { "sidecar_service": {} },
    "check": {
      "id": "jaeger-http-collector",
      "name": "Jaeger HTTP Collector TCP on port 14268",
      "tcp": "localhost:14268",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF
cat <<-EOF > /etc/consul.d/zipkin-http-collector.json
{
  "service": {
    "name": "zipkin-http-collector",
    "port": 9411,
    "tags": [
      "monitoring"
    ],
    "connect": { "sidecar_service": {} },
    "check": {
      "id": "zipkin-http-collector",
      "name": "Zipkin HTTP Collector TCP on port 9411",
      "tcp": "localhost:9411",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF
cat <<-EOF > /etc/consul.d/cassandra.json
{
  "service": {
    "name": "cassandra",
    "port": 9042,
    "tags": [
      "monitoring"
    ],
    "connect": { "sidecar_service": {} },
    "check": {
      "id": "cassandra",
      "name": "Cassandra CQL TCP on port 9042",
      "tcp": "localhost:9042",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF
cat <<-EOF > /etc/consul.d/prometheus.json
{
  "service": {
    "name": "prometheus",
    "port": 9090,
    "tags": [
      "monitoring"
    ],
    "check": {
      "id": "prometheus",
      "name": "Prometheus TCP on port 9090",
      "tcp": "localhost:9090",
      "interval": "5s",
      "timeout": "3s"
    }
  }
}
EOF
chown -R consul:consul /opt/consul/
chown -R consul:consul /etc/consul.d/
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10

#envoy
curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.16.0
cp /root/.getenvoy/builds/standard/*/linux_glibc/bin/envoy /usr/local/bin/envoy
cat <<EOF > /etc/systemd/system/envoy-jaeger.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for jaeger-http-collector -envoy-binary /usr/local/bin/envoy -token-file /etc/envoy/consul.token -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy-jaeger.service
sudo systemctl start envoy-jaeger.service
cat <<EOF > /etc/systemd/system/envoy-zipkin.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for zipkin-http-collector -envoy-binary /usr/local/bin/envoy -token-file /etc/envoy/consul.token -admin-bind 127.0.0.1:19001 -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy-zipkin.service
sudo systemctl start envoy-zipkin.service
cat <<EOF > /etc/systemd/system/envoy-cassandra.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for cassandra -envoy-binary /usr/local/bin/envoy -token-file /etc/envoy/consul.token -admin-bind 127.0.0.1:19003 -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable envoy-cassandra.service
sudo systemctl start envoy-cassandra.service

#jaeger
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cat <<-EOF > /docker-compose.yml
version: '3'
services:
    jaeger-collector:
      image: jaegertracing/jaeger-collector
      network_mode: host
      command: ["--cassandra.keyspace=jaeger_v1_dc1", "--cassandra.servers=127.0.0.1", "--collector.zipkin.http-port=9411"]
      restart: on-failure
      depends_on:
        - cassandra-schema

    jaeger-query:
      image: jaegertracing/jaeger-query
      network_mode: host
      command: ["--cassandra.keyspace=jaeger_v1_dc1", "--cassandra.servers=127.0.0.1"]
      restart: on-failure
      depends_on:
        - cassandra-schema

    jaeger-agent:
      image: jaegertracing/jaeger-agent
      network_mode: host
      command: ["--reporter.grpc.host-port=127.0.0.1:14250"]
      restart: on-failure
      depends_on:
        - jaeger-collector

    cassandra:
      image: cassandra:3.9
      network_mode: host

    cassandra-schema:
      image: jaegertracing/jaeger-cassandra-schema
      network_mode: host
      environment:
        - CQLSH_HOST=127.0.0.1
      depends_on:
        - cassandra

    prometheus:
        image: prom/prometheus:latest
        network_mode: host
        container_name: prometheus
EOF
/usr/local/bin/docker-compose up -d

#license
sudo crontab -l > consul
sudo echo "*/28 * * * * sudo service consul restart" >> consul
sudo crontab consul
sudo rm consul

#make sure the config was picked up
sudo service consul restart
sudo service envoy-jaeger restart
sudo service envoy-zipkin restart
sudo service envoy-cassandra restart

exit 0
