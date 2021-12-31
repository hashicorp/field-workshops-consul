module "payments_api" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.2.0"

  family            = "payments-api"
  port              = "8080"
  log_configuration = local.payments_api_log_config
  container_definitions = [{
    name             = "payments-api"
    image            = "hashicorpdemoapp/payments:v0.0.15"
    essential        = true
    logConfiguration = local.payments_api_log_config
    environment = [
      {
        name  = "NAME"
        value = "payments-api"
      }
    ]
  }]
  upstreams = [
    {
      destination_name = "redis"
      local_bind_port  = 6379
    },
    {
      destination_name = "vault"
      local_bind_port  = 8200
    },
    {
      destination_name = "jaeger-http-collector"
      local_bind_port  = 14268
    },
    {
      destination_name = "zipkin-http-collector"
      local_bind_port  = 9411
    }
  ]
  retry_join                     = ["provider=aws region=us-east-1 tag_key=Env tag_value=consul-${data.terraform_remote_state.infra.outputs.env}"]
  tls                            = true
  consul_server_ca_cert_arn      = data.terraform_remote_state.ecs.outputs.aws_secretsmanager_consul_ca_arn
  gossip_key_secret_arn          = data.terraform_remote_state.ecs.outputs.aws_secretsmanager_gossip_key_arn
  acls                           = true
  consul_client_token_secret_arn = data.terraform_remote_state.ecs.outputs.aws_secretsmanager_consul_client_token_arn
  acl_secret_name_prefix         = "consul-mc-lab"
  consul_datacenter              = "aws-us-east-1"
  consul_service_tags            = ["app","ecs"]

  consul_image = "public.ecr.aws/hashicorp/consul-enterprise:1.10.4-ent"

  additional_task_role_policies      = [data.terraform_remote_state.iam.outputs.aws_consul_iam_policy_arn]
  additional_execution_role_policies = [data.terraform_remote_state.iam.outputs.aws_consul_iam_policy_arn]
}
