output "aws_elasticache_cache_nodes" {
  value = aws_elasticache_cluster.redis.cache_nodes
}
#added in to include nia into mc
output "elasticache_sg" {
  value = aws_security_group.redis.id
}
