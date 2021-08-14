service "azure-west-us-2-terminating-gateway" {
   policy = "write"
}
service "postgres" {
   policy = "write"
}
service "vault" {
   policy = "write"
}
service "" {
   policy = "read"
}
agent_prefix "" {
  policy = "read"
}
