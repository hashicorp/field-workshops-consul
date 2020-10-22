output "postgres_fqdn" {
  value = azurerm_postgresql_server.postgres.fqdn
}

output "postgres_password" {
  value = random_password.pg.result
}

output "aws_elasticache_cache_nodes" {
  value = aws_elasticache_cluster.redis.cache_nodes
}
