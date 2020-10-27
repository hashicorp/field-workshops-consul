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

  service_account {
    email  = data.terraform_remote_state.iam.outputs.gcp_consul_service_account_email
    scopes = ["cloud-platform", "compute-rw"]
  }

  metadata_startup_script = data.template_file.gcp-server-init.rendered

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  tags = ["consul-${data.terraform_remote_state.infra.outputs.env}"]

}

data "template_file" "gcp-server-init" {
  template = file("${path.module}/scripts/gcp_consul_server.sh")
  vars = {
    primary_wan_gateway = "${data.terraform_remote_state.consul-primary.outputs.aws_mgw_public_ip}:443",
    internal_lb = "consul.consul-ilb.il4.us-central1.lb.${var.gcp_project_id}.internal"
  }
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
    email  = data.terraform_remote_state.iam.outputs.gcp_consul_service_account_email
    scopes = ["cloud-platform", "compute-rw"]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  metadata_startup_script = data.template_file.gcp-mgw-init.rendered

}

data "template_file" "gcp-mgw-init" {
  template = file("${path.module}/scripts/gcp_mesh_gateway.sh")
  vars = {
    env = data.terraform_remote_state.infra.outputs.env
  }
}

resource "google_compute_instance_group" "consul" {
  name        = "consul-servers"
  description = "Consul servers"

  instances = [
    google_compute_instance.consul.self_link,
  ]

  named_port {
    name = "http"
    port = "8500"
  }

  zone    = "us-central1-a"
  network = data.terraform_remote_state.infra.outputs.gcp_shared_svcs_network_self_link
}

module "gce-ilb" {
  source           = "GoogleCloudPlatform/lb-internal/google"
  version          = "~> 2.0"
  region           = "us-central1"
  name             = "consul-ilb"
  network          = "vpc-shared-svcs"
  subnetwork       = "shared"
  ports            = [local.named_ports[0].port]
  source_ip_ranges = ["0.0.0.0"]
  source_tags      = []
  target_tags      = []
  health_check     = local.health_check
  service_label    = "consul"
  backends = [
    { group = google_compute_instance_group.consul.id, description = "" },
  ]
}
