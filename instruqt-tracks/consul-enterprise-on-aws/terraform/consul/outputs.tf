output "env" {
  value = module.consul.env
}

output "lb" {
  value = aws_lb.consul.dns_name
}

output "master_token" {
  value     = module.consul.master_token
  sensitive = true
}

output "agent_server_token" {
  value     = module.consul.agent_server_token
  sensitive = true
}

output "gossip_key" {
  value     = module.consul.gossip_key
  sensitive = true
}
