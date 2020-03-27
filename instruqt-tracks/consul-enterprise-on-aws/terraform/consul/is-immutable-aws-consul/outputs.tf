output "env" {
  value = random_id.environment_name.hex
}

output "target_group" {
  value = aws_lb.consul.dns_name
}

output "master_token" {
  value = random_uuid.consul_master_token.result
}

output "agent_server_token" {
  value = random_uuid.consul_agent_server_token.result
}

output "snapshot_token" {
  value = random_uuid.consul_snapshot_token.result
}

output "gossip_key" {
  value = random_uuid.consul_gossip_encryption_key.result
}
