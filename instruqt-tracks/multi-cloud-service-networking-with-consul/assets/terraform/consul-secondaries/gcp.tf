data "google_project" "project" {}

resource "google_compute_address" "static" {
  name         = "consul-ipv4-address"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "mgw" {
  name         = "mgw-ipv4-address"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "consul" {
  name         = "consul-server"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = "vpc-shared-svcs"
    subnetwork = "shared"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = data.template_file.gcp-server-init.rendered

  tags = ["consul-${data.terraform_remote_state.infra.outputs.env}"]

}

data "template_file" "gcp-server-init" {
  template = file("${path.module}/scripts/gcp_consul_server.sh")
  vars = {
    ca_cert             = tls_self_signed_cert.shared_ca.cert_pem
    cert                = tls_locally_signed_cert.gcp_consul_server.cert_pem,
    key                 = tls_private_key.gcp_consul_server.private_key_pem
    primary_wan_gateway = "${aws_instance.mesh_gateway.public_ip}:443"
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

  dns_names    = ["consul-server-0.server.gcp-us-central-1.consul", "server.gcp-us-central-1.consul", "localhost"]
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

resource "google_compute_firewall" "consul" {
  name    = "allow-consul-external"
  network = "vpc-shared-svcs"

  allow {
    protocol = "tcp"
    ports    = ["22", "8500", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "consul-gossip" {
  name    = "allow-consul-internal"
  network = "vpc-shared-svcs"

  allow {
    protocol = "tcp"
    ports    = ["8300", "8301"]
  }

  allow {
    protocol = "udp"
    ports    = ["8301"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "mgw" {
  name         = "consul-mgw"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = "vpc-shared-svcs"
    subnetwork = "shared"
    access_config {
      nat_ip = google_compute_address.mgw.address
    }
  }

  service_account {
    email  = google_service_account.consul_service_account.email
    scopes = ["cloud-platform", "compute-rw"]
  }

  metadata_startup_script = data.template_file.gcp-mgw-init.rendered

}

data "template_file" "gcp-mgw-init" {
  template = file("${path.module}/scripts/gcp_mesh_gateway.sh")
  vars = {
    env     = data.terraform_remote_state.infra.outputs.env
    ca_cert = tls_self_signed_cert.shared_ca.cert_pem
    project = data.google_project.project.id
  }
}

resource "google_service_account" "consul_service_account" {
  account_id   = "consul"
  display_name = "Consul"
}

resource "google_project_iam_member" "consul" {
  member = "serviceAccount:${google_service_account.consul_service_account.email}"
  role   = "roles/compute.viewer"
}
