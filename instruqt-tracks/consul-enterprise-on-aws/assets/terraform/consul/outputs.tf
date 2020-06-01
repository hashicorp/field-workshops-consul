output "env" {
  value = module.consul.env
}

output "lb" {
  value = aws_lb.consul.dns_name
}

output "ca" {
  value = module.consul_tls.consul_tls_config.ca_cert
}

output "master_token" {
  value     = module.consul.master_token
  sensitive = true
}

output "agent_server_token" {
  value     = module.consul.agent_server_token
  sensitive = true
}

output "snapshot_token" {
  value     = module.consul.snapshot_token
  sensitive = true
}

output "gossip_key" {
  value     = module.consul.gossip_key
  sensitive = true
}

