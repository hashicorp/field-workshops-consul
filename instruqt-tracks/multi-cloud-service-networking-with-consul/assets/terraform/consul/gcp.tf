resource "google_compute_address" "static" {
  name = "ipv4-address"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "consul" {
  project      = "p-rp72371sw14jeeggyk2hbpp1ynen"
  name         = "consul-server"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "vpc-shared-svcs"
    subnetwork  = "shared"
    subnetwork_project = "p-rp72371sw14jeeggyk2hbpp1ynen"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = data.template_file.gcp-server-init.rendered

}

data "template_file" "gcp-server-init" {
  template = file("${path.module}/scripts/gcp_consul_server.sh")
  vars = {
    ca_cert = tls_self_signed_cert.shared_ca.cert_pem
    cert    = tls_locally_signed_cert.gcp_consul_server.cert_pem,
    key     = tls_private_key.gcp_consul_server.private_key_pem
  }
}

resource "tls_private_key" "gcp_consul_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "gcp_consul_server" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.gcp_consul_server.private_key_pem

  subject {
    common_name = "consul-server-0.server.gcp-us-central-1.consul"
  }

  dns_names    = ["server.gcp-us-central-1.consul", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "gcp_consul_server" {
  cert_request_pem   = tls_cert_request.gcp_consul_server.cert_request_pem
  ca_key_algorithm   = tls_private_key.shared_ca.algorithm
  ca_private_key_pem = tls_private_key.shared_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.shared_ca.cert_pem

  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth"
  ]
}
