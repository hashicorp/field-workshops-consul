module "acl_controller" {
  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.3.0"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.vpc_region
      awslogs-stream-prefix = "consul-acl-controller"
    }
  }
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  consul_server_http_addr           = data.terraform_remote_state.hcp.outputs.hcp_consul_private_endpoint_url
  ecs_cluster_arn                   = aws_ecs_cluster.this.arn
  region                            = var.vpc_region
  subnets                           = var.private_subnets_ids
  name_prefix                       = var.name
}

module "product-api" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.3.0"
  consul_image      = "hashicorp/consul-enterprise:1.11.2-ent"

  family            = "${var.name}-product-api"
  cpu               = 1024
  memory            = 2048
  port              = "9090"
  log_configuration = local.product-api_log_config
  container_definitions = [{
    name             = "product-api"
    image            = "hashicorpdemoapp/product-api:v0.0.19"
    essential        = true
    logConfiguration = local.product-api_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-product-api"
      },
      {
        name  = "DB_CONNECTION"
        value = "host=product-db port=5432 user=postgres password=password dbname=products sslmode=disable"
      },
      {
        name = "BIND_ADDRESS"
        value = ":9090"
      }
    ]
  }]
  upstreams = [
    {
      destinationName = "postgres"
      localBindPort  = 5432
    }
  ]
  // Strip away the https prefix from the Consul network address
  retry_join                     = [substr(data.terraform_remote_state.hcp.outputs.hcp_consul_private_endpoint_url, 8, -1)]
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = data.terraform_remote_state.hcp.outputs.consul_datacenter
#  consul_agent_configuration     = "partition = \"ecs-services\""
#  consul_partition               = "ecs-services"

  depends_on = [module.acl_controller]
}