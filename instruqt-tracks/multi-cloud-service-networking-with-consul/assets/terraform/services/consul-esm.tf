resource "consul_node" "aws-elastic-cache" {
  provider = consul.aws

  name    = "aws-elastic-cache"
  address = aws_elasticache_cluster.redis.cache_nodes.0.address

  meta = {
    "external-node"  = "true"
    "external-probe" = "false"
  }
}

resource "consul_service" "aws-elastic-cache" {
  provider = consul.aws

  name = "redis"
  node = consul_node.aws-elastic-cache.name
  port = 6379

  check {
    check_id = "service:elastic-cache"
    name     = "Redis health check"
    status   = "passing"
    tcp      = "${aws_elasticache_cluster.redis.cache_nodes.0.address}:6379"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_node" "azure-pg" {
  provider = consul.azure

  name    = "azure-pg"
  address = azurerm_postgresql_server.postgres.fqdn

  meta = {
    "external-node"  = "true"
    "external-probe" = "false"
  }
}

resource "consul_service" "azure-pg" {
  provider = consul.azure

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
