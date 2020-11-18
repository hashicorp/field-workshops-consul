operator = "write"
acl = "write"
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "write"
  intentions = "write"
}
