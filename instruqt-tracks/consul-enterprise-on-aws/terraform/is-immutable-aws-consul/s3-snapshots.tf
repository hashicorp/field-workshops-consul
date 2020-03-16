resource "aws_s3_bucket" "consul_data" {
  count  = var.enable_snapshots ? 1 : 0
  bucket = "${random_id.environment_name.hex}-consul-data"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "consul_data" {
  count                   = var.enable_snapshots ? 1 : 0
  bucket                  = aws_s3_bucket.consul_data[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}