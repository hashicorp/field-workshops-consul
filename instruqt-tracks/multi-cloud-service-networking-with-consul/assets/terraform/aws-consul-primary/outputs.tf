output "aws_consul_public_ip" {
  value = aws_instance.consul.public_ip
}

output "aws_mgw_public_ip" {
  value = aws_instance.mesh_gateway.public_ip
}

output "aws_consul_sg" {
  value = aws_security_group.consul.id
}
