resource "aws_ecs_service" "payments_api" {
  name            = "payments-api"
  cluster         = data.terraform_remote_state.ecs.outputs.aws_ecs_cluster_arn
  task_definition = module.payments_api.task_definition_arn
  desired_count   = 2
  network_configuration {
    subnets         = data.terraform_remote_state.infra.outputs.aws_shared_svcs_private_subnets
    security_groups = [data.terraform_remote_state.consul.outputs.aws_consul_sg]
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
}
