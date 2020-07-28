node "payments" {
  policy = "write"
}

agent "payments" {
  policy = "write"
}

key_prefix "_rexec" {
  policy = "write"
}

service "payments" {
	policy = "write"
}

service "payments-sidecar-proxy" {
	policy = "write"
}

service_prefix "" {
	policy = "read"
}

node_prefix "" {
	policy = "read"
}