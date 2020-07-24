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

service_prefix "payments-1-sidecar-proxy" {
	policy = "write"
}

service_prefix "" {
	policy = "read"
}

node_prefix "" {
	policy = "read"
}