resource "aws_security_group" "example_client_app_alb" {
  name   = "${var.name}-example-client-app-alb"
  vpc_id = data.terraform_remote_state.vpc.outputs.ecs_dev_aws_vpc_id

  ingress {
    description = "Access to example client application."
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.user_public_ip}"]
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
  source_security_group_id = aws_security_group.example_client_app_alb.id
  security_group_id        = data.aws_security_group.vpc_default.id
}


#locals {
#  ingress_consul_rules = [
#    {
#      description = "Consul LAN Serf (tcp)"
#      port        = 8301
#      protocol    = "tcp"
#    },
#    {
#      description = "Consul LAN Serf (udp)"
#      port        = 8301
#      protocol    = "udp"
#    },
#  ]
#
#  ecs_security_ids = [module.ecs.cluster_primary_security_group_id]
#
#  hcp_consul_security_groups = flatten([
#    for _, sg in local.ecs_security_ids : [
#      for _, rule in local.ingress_consul_rules : {
#        security_group_id = sg
#        description       = rule.description
#        port              = rule.port
#        protocol          = rule.protocol
#      }
#    ]
#  ])
#}
#
#resource "aws_security_group_rule" "hcp_consul_existing_grp" {
#  count             = length(local.hcp_consul_security_groups)
#  description       = local.hcp_consul_security_groups[count.index].description
#  protocol          = local.hcp_consul_security_groups[count.index].protocol
#  security_group_id = local.hcp_consul_security_groups[count.index].security_group_id
#  cidr_blocks       = [local.hcp_hvn_cidr_block]
#  from_port         = local.hcp_consul_security_groups[count.index].port
#  to_port           = local.hcp_consul_security_groups[count.index].port
#  type              = "ingress"
#}
