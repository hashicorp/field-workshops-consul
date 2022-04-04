locals {
  ingress_consul_rules = [
    {
      description = "Consul LAN Serf (tcp)"
      port        = 8301
      protocol    = "tcp"
    },
    {
      description = "Consul LAN Serf (udp)"
      port        = 8301
      protocol    = "udp"
    },
  ]
}

resource "aws_security_group" "hcp_consul" {
  name_prefix = "hcp_consul"
  description = "HCP Consul security group"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "hcp_consul_new_grp" {
  count             = length(local.ingress_consul_rules)
  description       = local.ingress_consul_rules[count.index].description
  protocol          = local.ingress_consul_rules[count.index].protocol
  security_group_id = aws_security_group.hcp_consul.id
  cidr_blocks       = [local.vpc_cidr_block]
  from_port         = local.ingress_consul_rules[count.index].port
  to_port           = local.ingress_consul_rules[count.index].port
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_all_egress" {
  description       = "Allow egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.hcp_consul.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "allow_self" {
  description       = "Allow members of this security group to communicate over all ports"
  protocol          = "-1"
  security_group_id = aws_security_group.hcp_consul.id
  self              = true
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}