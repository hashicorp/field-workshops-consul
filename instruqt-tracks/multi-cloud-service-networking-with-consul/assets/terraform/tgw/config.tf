resource "consul_config_entry" "terminating_gateway" {
  name = "terminating-gateway"
  kind = "terminating-gateway"

  config_json = jsonencode({
    Services = [{ Name = "postgres" }]
  })
}
