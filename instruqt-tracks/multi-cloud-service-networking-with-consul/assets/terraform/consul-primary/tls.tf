resource "tls_private_key" "shared_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "shared_ca" {
  key_algorithm         = "ECDSA"
  private_key_pem       = tls_private_key.shared_ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]

  subject {
    common_name    = "HashiCorp Example CA"
    country        = "US"
    province       = "CA"
    locality       = "San Francisco"
    street_address = ["101 Second Street"]
    postal_code    = "94105"
    organization   = "HashiCorp Inc."
  }
}
