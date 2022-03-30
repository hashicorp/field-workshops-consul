
//FIXME: 
// https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry
// https://www.consul.io/docs/connect/config-entries/exported-services

resource "consul_config_entry" "exported_ecs_services" {
  kind = "exported-services"
#  partition = "ecs-services"
  # Note that only "global" is currently supported for proxy-defaults and that
  # Consul will override this attribute if you set it to anything else.
  name = "ecs-services"

  config_json = jsonencode({
    Services = [
      {
        Name = "consul-ecs-public-api"
        Namespace = "default"
        Consumers = [
          {
            Partition = "eks-dev"
          },
        ]
      }
    ]
  })
}

#resource "consul_config_entry" "exported_eks_dev_services" {
#  kind = "exported-services"
##  partition = "eks-dev"
#  # Note that only "global" is currently supported for proxy-defaults and that
#  # Consul will override this attribute if you set it to anything else.
#  name = "eks-dev"
#
#  config_json = jsonencode({
#    Services = [
#      {
#        Name = "<name of service to export>"
#        Namespace = "<namespace in the partition containing the service to export>"
#        Consumers = [
#          {
#            Partition = "<name of the partition that will dial the exported service>"
#          },
#        ]
#      }
#    ]
#  })
#}
