output "env" {
  value = module.consul.outputs.env
}

output "lb" {
  value = aws_lb.consul.dns_name
}
