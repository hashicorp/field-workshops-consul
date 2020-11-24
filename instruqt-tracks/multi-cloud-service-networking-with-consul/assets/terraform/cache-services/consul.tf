resource "consul_node" "aws-elastic-cache" {
  name    = "aws-elastic-cache"
  address = aws_elasticache_cluster.redis.cache_nodes.0.address

  meta = {
    "external-node"  = "true"
    "external-probe" = "false"
  }
}

resource "consul_service" "aws-elastic-cache" {
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
