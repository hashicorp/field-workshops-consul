operator = "write"
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
acl = "write"
service_prefix "" {
  policy = "read"
  intentions = "read"
}
