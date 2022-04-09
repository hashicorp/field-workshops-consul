locals {
  frontend_name = "frontend"
  frontend_port = 3000
}

resource "aws_ecs_service" "frontend" {
  name            = local.frontend_name
  cluster         = aws_ecs_cluster.this.arn
  task_definition = module.frontend.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = local.ecs_dev_private_subnets
#    security_groups = [var.ecs_security_group]
  }
  launch_type    = "FARGATE"
  propagate_tags = "TASK_DEFINITION"
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = local.frontend_name
    container_port   = local.frontend_port
  }
  enable_execute_command = true
}

module "frontend" {
  source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                  = "0.4.0"
  consul_image             = "hashicorp/consul-enterprise:1.11.4-ent"
  consul_partition         = "ecs-services"
  consul_namespace         = "default"

#  requires_compatibilities = ["FARGATE"]
  family                   = "frontend"
  cpu               = 1024
  memory            = 2048
  port                     = "3000"
  log_configuration        = local.frontend_log_config
  container_definitions = [{
    name             = local.frontend_end
    image            = "hashicorpdemoapp/frontend:v1.0.3"
    essential        = true
    logConfiguration = local.frontend_log_config
    environment = [{
        name  = "NAME"
        value = local.frontend_name
      },
      {
        name = "NEXT_PUBLIC_PUBLIC_API_URL",
        #value = "${hcp_consul_cluster.example.consul_public_endpoint_url}:8081"
        value = "http://${aws_lb.frontend.dns_name}:8081"
      }
    ]
    linuxParameters = {
      initProcessEnabled = true
    }
    portMappings = [
      {
        containerPort = local.frontend_port
        hostPort      = local.frontend_port
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destinationName = "public-api"
      localBindPort  = 8081
    }
  ]
  retry_join                     = [substr(local.hcp_consul_private_endpoint_url, 8, -1)]
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  consul_datacenter              = local.consul_datacenter

  additional_task_role_policies = [aws_iam_policy.execute_command.arn]
  depends_on = [module.acl_controller]

}

