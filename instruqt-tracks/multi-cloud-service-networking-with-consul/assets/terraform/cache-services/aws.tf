resource "aws_elasticache_subnet_group" "default" {
  name       = "redis-cache-subnet-${data.terraform_remote_state.infra.outputs.env}"
  subnet_ids = [data.terraform_remote_state.infra.outputs.aws_shared_svcs_private_subnets[0]]
}

resource "aws_security_group" "redis" {
  name        = "redis-sg"
  description = "ElastiCache Redis Securtity Group"
  vpc_id      = data.terraform_remote_state.infra.outputs.aws_shared_svcs_vpc

  ingress {
    from_port   = "6379"
    to_port     = "6379"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster-example"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.redis.id]
}
