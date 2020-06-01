resource "tls_private_key" "shared_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "shared_ca" {
  key_algorithm         = "ECDSA"
  private_key_pem       = tls_private_key.shared_ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = var.ca_validity

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]

  subject {
    common_name    = "HashiCorp Example CA ${var.environment_name}"
    country        = "US"
    province       = "CA"
    locality       = "San Francisco"
    street_address = ["101 Second Street"]
    postal_code    = "94105"
    organization   = "HashiCorp Inc."
  }
}

///////////////////////
// Consul Certificates
///////////////////////

resource "tls_private_key" "consul_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "consul_server" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.consul_server.private_key_pem

  subject {
    common_name = "server.${var.consul_datacenter}.consul"
  }

  dns_names    = var.dns_names
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "consul_server" {
  cert_request_pem   = tls_cert_request.consul_server.cert_request_pem
  ca_key_algorithm   = tls_private_key.shared_ca.algorithm
  ca_private_key_pem = tls_private_key.shared_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.shared_ca.cert_pem

  validity_period_hours = var.server_validity

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth"
  ]
}
