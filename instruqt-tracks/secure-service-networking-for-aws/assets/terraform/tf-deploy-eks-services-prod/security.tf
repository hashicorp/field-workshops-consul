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

resource "aws_security_group_rule" "hcp_consul_eks_prod" {
  count             = length(local.ingress_consul_rules)
  description       = local.ingress_consul_rules[count.index].description
  protocol          = local.ingress_consul_rules[count.index].protocol
  security_group_id = module.eks.cluster_primary_security_group_id
  cidr_blocks       = [local.vpc_cidr_block]
  from_port         = local.ingress_consul_rules[count.index].port
  to_port           = local.ingress_consul_rules[count.index].port
  type              = "ingress"
}
