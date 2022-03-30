module "acl_controller" {
#  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
#  version = "0.3.0"
  source = "git::https://github.com/hashicorp/terraform-aws-consul-ecs.git//modules/acl-controller?ref=cthain-add-ns-at"
  consul_ecs_image                  = "docker.mirror.hashicorp.services/hashicorpdev/consul-ecs:cfe3df3"
  consul_partitions_enabled         = true
  consul_partition                  = "ecs-services"
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

module "public-api" {
#  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
#  version = "0.3.0"
  source = "git::https://github.com/hashicorp/terraform-aws-consul-ecs.git//modules/mesh-task?ref=cthain-add-ns-at"
  consul_image      = "hashicorp/consul-enterprise:1.11.4-ent"
  consul_ecs_image                  = "docker.mirror.hashicorp.services/hashicorpdev/consul-ecs:cfe3df3"
#  consul_partitions_enabled         = "-partitions-enabled"
  consul_partition                  = "ecs-services"
  consul_namespace                  = "default"

  family            = "${var.name}-public-api"
  cpu               = 1024
  memory            = 2048
  port              = "9090"
  log_configuration = local.product-api_log_config
  container_definitions = [{
    name             = "product-api"
    image            = "hashicorpdemoapp/public-api:v0.0.5"
    essential        = true
    logConfiguration = local.product-api_log_config
    environment = [
      {
        name  = "PAYMENT_API_URI"
        value = "http://payments:9090"
      },
      {
        name  = "PRODUCT_API_URI"
        value = "http://product-api:9090"
      },
      {
        name = "BIND_ADDRESS"
        value = ":8080"
      }
    ]
  }]
  upstreams = [
    {
      destinationName = "product-api"
      destinationPartition = "eks-dev"
      destinationNamespace = "default"
      localBindPort  = 9090
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

  depends_on = [module.acl_controller]
}