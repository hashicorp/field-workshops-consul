resource "consul_config_entry" "cassandra" {
  name = "cassandra"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}

resource "consul_config_entry" "jaeger-http-collector" {
  name = "jaeger-http-collector"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}

resource "consul_config_entry" "zipkin-http-collector" {
  name = "zipkin-http-collector"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}
