module "acl_controller" {
  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.2.0"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-acl-controller"
    }
  }
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  consul_server_ca_cert_arn         = aws_secretsmanager_secret.consul_ca_cert.arn
  consul_server_http_addr           = "http://${var.consul_cluster_addrs[0]}:8500" # Change this to https and port 8501 if you are using HTTPS
  ecs_cluster_arn                   = aws_ecs_cluster.this.arn
  region                            = var.region
  subnets                           = var.private_subnets_ids
  name_prefix                       = var.name
}
