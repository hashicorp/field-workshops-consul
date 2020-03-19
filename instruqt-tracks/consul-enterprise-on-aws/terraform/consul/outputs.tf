output "consul_lb" {
  value       = aws_lb.consul.dns_name
}
