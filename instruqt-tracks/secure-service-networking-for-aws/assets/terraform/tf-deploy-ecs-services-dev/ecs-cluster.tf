locals {
  aws_suffix = random_string.rand_aws_suffix.result
  ecs_name = "consul-ecs-${random_string.rand_aws_suffix.result}"
  launch_type = "FARGATE"
}

resource "random_string" "rand_aws_suffix" {
  length  = 6
  special = false
}

resource "aws_ecs_cluster" "this" {
  name               = var.name
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}

// Policy that allows execution of remote commands in ECS tasks.
resource "aws_iam_policy" "execute_command" {
  name   = "ecs-execute-command-${local.aws_suffix}"
  path   = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}