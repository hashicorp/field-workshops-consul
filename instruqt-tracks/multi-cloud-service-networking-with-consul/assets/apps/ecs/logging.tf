locals {
  payments_api_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = data.terraform_remote_state.ecs.outputs.aws_cloudwatch_log_group_name
      awslogs-region        = var.region
      awslogs-stream-prefix = "payments-api"
    }
  }
}
