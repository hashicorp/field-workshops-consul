output "env" {
  value = module.consul.env
}

output "lb" {
  value = aws_lb.consul.dns_name
}
