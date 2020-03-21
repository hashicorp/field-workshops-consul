output "instruqt_env" {
  value       = random_id.environment_name.hex
}

output "consul_lb" {
  value       = aws_lb.consul.dns_name
}
