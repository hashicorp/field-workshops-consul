resource "aws_security_group" "frontend" {
  name   = "frontend-alb"
  vpc_id = local.ecs_dev_aws_vpc_id

  ingress {
    description = "Access to frontend Web UI."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access to GraphQL API."
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access to frontend Web UI."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Access to GraphQL API."
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_from_client_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  security_group_id        = data.aws_security_group.vpc_default.id
}

resource "aws_security_group_rule" "eks_dev_mesh_gateway_ingress" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  cidr_blocks              = [ local.ecs_dev_vpc_cidr_block ]
  security_group_id        = local.eks_dev_cluster_primary_security_group_id
}
