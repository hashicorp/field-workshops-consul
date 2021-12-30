output "aws_secretsmanager_consul_ca_arn" {
  value = aws_secretsmanager_secret.consul_ca_cert.arn
}

output "aws_secretsmanager_gossip_key_arn" {
  value = aws_secretsmanager_secret.gossip_key.arn
}

output "aws_secretsmanager_consul_client_token_arn" {
  value = module.acl_controller.client_token_secret_arn
}

output "aws_cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "aws_ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}
