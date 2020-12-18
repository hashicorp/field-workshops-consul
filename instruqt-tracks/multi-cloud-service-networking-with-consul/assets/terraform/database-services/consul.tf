resource "consul_node" "azure-pg" {
  name    = "azure-pg"
  address = azurerm_postgresql_server.postgres.fqdn

  meta = {
    "external-node"  = "true"
    "external-probe" = "false"
  }
}

resource "consul_service" "azure-pg" {
  name = "postgres"
  node = consul_node.azure-pg.name
  port = 5432

  check {
    check_id = "service:postgres"
    name     = "Postgres health check"
    status   = "passing"
    tcp      = "${azurerm_postgresql_server.postgres.fqdn}:5432"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_config_entry" "postgres" {
  name = "postgres"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}
