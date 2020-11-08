resource "consul_config_entry" "aws-terminating_gateway" {
  name = "aws-us-east-1-terminating-gateway"
  kind = "terminating-gateway"

  config_json = jsonencode({
    Services = [{ Name = "redis" }, { Name = "vault" }]
  })
}

resource "consul_config_entry" "azure-terminating_gateway" {
  name = "azure-west-us-2-terminating-gateway"
  kind = "terminating-gateway"

  config_json = jsonencode({
    Services = [{ Name = "postgres" }, { Name = "vault" }]
  })
}
