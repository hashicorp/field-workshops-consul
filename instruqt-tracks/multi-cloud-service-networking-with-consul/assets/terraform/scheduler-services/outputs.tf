output "aws_nomad_server_public_ip" {
  value = aws_instance.nomad.public_ip
}

output "aws_nomad_worker_public_ip" {
  value = aws_instance.nomad-client.public_ip
}
