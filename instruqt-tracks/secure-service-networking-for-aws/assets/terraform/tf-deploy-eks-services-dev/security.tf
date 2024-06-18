# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

  eks_security_ids = [module.eks.cluster_primary_security_group_id]

  hcp_consul_security_groups = flatten([
    for _, sg in local.eks_security_ids : [
      for _, rule in local.ingress_consul_rules : {
        security_group_id = sg
        description       = rule.description
        port              = rule.port
        protocol          = rule.protocol
      }
    ]
  ])
}

resource "aws_security_group_rule" "hcp_consul_existing_grp" {
  count             = length(local.hcp_consul_security_groups)
  description       = local.hcp_consul_security_groups[count.index].description
  protocol          = local.hcp_consul_security_groups[count.index].protocol
  security_group_id = local.hcp_consul_security_groups[count.index].security_group_id
  cidr_blocks       = [local.hcp_hvn_cidr_block]
  from_port         = local.hcp_consul_security_groups[count.index].port
  to_port           = local.hcp_consul_security_groups[count.index].port
  type              = "ingress"
}
