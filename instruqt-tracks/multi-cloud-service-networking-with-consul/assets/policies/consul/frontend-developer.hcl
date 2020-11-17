namespace "frontend" {
  service_prefix "" {
    policy     = "read"
    intentions = "write"
  }
}
namespace_prefix "" {
  node_prefix "" {
    policy = "read"
  }
  service_prefix "" {
    policy = "read"
  }
  acl = "read"
}
