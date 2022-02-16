service "cts" {
   policy = "write"
}
service "" {
   policy = "read"
}
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

key_prefix "consul-terraform-sync/" {
  policy = "write"
}

session_prefix "" {
  policy = "write"
}
