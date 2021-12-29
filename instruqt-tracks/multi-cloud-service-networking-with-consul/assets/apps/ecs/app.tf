module "example_client_app" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.2.0"

  family            = "${var.name}-example-client-app"
  port              = "9090"
  log_configuration = local.example_client_app_log_config
  container_definitions = [{
    name             = "example-client-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_client_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-client-app"
      },
      {
        name  = "UPSTREAM_URIS"
        value = "http://localhost:1234"
      }
    ]
    portMappings = [
      {
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destination_name = "${var.name}-example-server-app"
      local_bind_port  = 1234
    }
  ]
  retry_join                     = var.consul_cluster_addrs
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = var.consul_datacenter

  additional_task_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]
  additional_execution_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]

  depends_on = [module.acl_controller, module.example_server_app]
}

module "example_server_app" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.2.0"

  family            = "${var.name}-example-server-app"
  port              = "9090"
  log_configuration = local.example_server_app_log_config
  container_definitions = [{
    name             = "example-server-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_server_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-server-app"
      }
    ]
  }]
  retry_join                     = var.consul_cluster_addrs
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = var.consul_datacenter

  additional_task_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]
  additional_execution_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]

  depends_on = [module.acl_controller]
}

module "payments_app" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.2.0"

  family            = "payments-app"
  port              = "8080"
  log_configuration = local.example_server_app_log_config
  container_definitions = [{
    name             = "payments-app"
    image            = "hashicorpdemoapp/payments:v0.0.15"
    essential        = true
    logConfiguration = local.example_server_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "payments-app"
      }
    ]
  }]
  upstreams = [
    {
      destination_name = "redis"
      local_bind_port  = 6379
    }
  ]
  retry_join                     = var.consul_cluster_addrs
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = var.consul_datacenter

  consul_image = "public.ecr.aws/hashicorp/consul-enterprise:1.10.4-ent"

  additional_task_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]
  additional_execution_role_policies = ["arn:aws:iam::431013490658:policy/consul-ylng"]

  depends_on = [module.acl_controller]
}
