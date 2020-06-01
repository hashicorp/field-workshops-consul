output "consul_tls_config" {
  value = {
    ca_cert = tls_self_signed_cert.shared_ca.cert_pem
    cert    = tls_locally_signed_cert.consul_server.cert_pem,
    key     = tls_private_key.consul_server.private_key_pem
  }
}

output "shared_ca_cert" {
  value = tls_self_signed_cert.shared_ca.cert_pem
}