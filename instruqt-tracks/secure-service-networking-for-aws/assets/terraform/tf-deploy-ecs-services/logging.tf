resource "aws_cloudwatch_log_group" "log_group" {
  name = var.name
}

locals {
  product-api_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.vpc_region
      awslogs-stream-prefix = "app"
    }
  }

#  example_client_app_log_config = {
#    logDriver = "awslogs"
#    options = {
#      awslogs-group         = aws_cloudwatch_log_group.log_group.name
#      awslogs-region        = var.vpc_region
#      awslogs-stream-prefix = "client"
#    }
#  }
}
