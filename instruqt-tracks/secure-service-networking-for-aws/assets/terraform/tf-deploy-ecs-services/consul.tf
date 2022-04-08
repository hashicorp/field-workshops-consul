// Create Admin Partition and Namespace for the client
resource "consul_admin_partition" "ecs-services" {
  name        = "ecs-services"
  description = "Partition for ecs service"
}

resource "consul_config_entry" "proxy_defaults" {

  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    MeshGateway = {
      Mode = "local"
    }
  })
}

//FIXME: 
// https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry
// https://www.consul.io/docs/connect/config-entries/exported-services

resource "consul_config_entry" "exported_eks_services" {
  kind = "exported-services"
  # Note that only "global" is currently supported for proxy-defaults and that
  # Consul will override this attribute if you set it to anything else.
  name = "ecs-services"

  config_json = jsonencode({
    Services = [
      {
        Name = "product-api"
        Partition = "eks-dev"
        Namespace = "default"
        Consumers = [
          {
            Partition = consul_admin_partition.ecs-services.name
          },
        ]
      },
      {
        Name = "payments"
        Partition = "eks-dev"
        Namespace = "default"
        Consumers = [
          {
            Partition = consul_admin_partition.ecs-services.name
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
