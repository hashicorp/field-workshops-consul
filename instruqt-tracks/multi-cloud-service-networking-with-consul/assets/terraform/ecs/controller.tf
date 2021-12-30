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
  consul_server_http_addr           = "http://${data.terraform_remote_state.consul.outputs.aws_consul_public_ip}:8500" # Change this to https and port 8501 if you are using HTTPS
  ecs_cluster_arn                   = aws_ecs_cluster.this.arn
  region                            = var.region
  subnets                           = data.terraform_remote_state.infra.outputs.aws_shared_svcs_private_subnets
  name_prefix                       = var.name
}
