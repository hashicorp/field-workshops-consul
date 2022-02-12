output "aws_elasticache_cache_nodes" {
  value = aws_elasticache_cluster.redis.cache_nodes
}
output "elasticache_sg" {
  value = aws_security_group.redis.id
}
