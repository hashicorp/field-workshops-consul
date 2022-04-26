resource "consul_config_entry" "public_api_intention" {
  name = local.public_api_name
  kind = "service-intentions"
  partition = "ecs-dev"
  namespace = "default"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = local.frontend_name
        Precedence = 9
        Type       = "consul"
        Namespace  = "default"
        Partition  = local.frontend_partition
      }
    ]
  })
}

resource "consul_config_entry" "product_api_intention" {
  name = "product-api"
  kind = "service-intentions"
  partition = "eks-dev"
  namespace = "default"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = local.public_api_name
        Precedence = 9
        Type       = "consul"
        Namespace  = "default"
        Partition  = "eks-dev"
      }
    ]
  })
}

resource "consul_config_entry" "payments_intention" {
  name = "payments"
  kind = "service-intentions"
  partition = "eks-dev"
  namespace = "default"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = local.public_api_name
        Precedence = 9
        Type       = "consul"
        Namespace  = "default"
        Partition  = "eks-dev"
      }
    ]
  })
}