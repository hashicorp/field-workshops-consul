output "instruqt_env" {
  value       = random_id.environment_name.hex
}

output "consul_lb" {
  value       = aws_lb.consul.dns_name
}

output "consul_master_token" {
  value       = random_uuid.consul_master_token.result
}
