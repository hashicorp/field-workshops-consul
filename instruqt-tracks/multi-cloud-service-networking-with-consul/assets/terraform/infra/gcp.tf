module "gcp-vpc-shared-svcs" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.gcp_project_id
  network_name = "vpc-shared-svcs"
  subnets = [
    {
      subnet_name           = "shared"
      subnet_ip             = "10.1.0.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "false"
      subnet_flow_logs      = "true"
    },
  ]
}

module "gcp-vpc-app" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.gcp_project_id
  network_name = "vpc-app"
  subnets = [
    {
      subnet_name           = "app"
      subnet_ip             = "10.2.0.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "false"
      subnet_flow_logs      = "true"
    },
  ]
}

resource "google_compute_network_peering" "shared-to-app" {
  name         = "shared-to-app"
  network      = module.gcp-vpc-shared-svcs.network.network.id
  peer_network = module.gcp-vpc-app.network.network.id
}

resource "google_compute_network_peering" "app-to-shared" {
  name         = "app-to-shared"
  network      = module.gcp-vpc-app.network.network.id
  peer_network = module.gcp-vpc-shared-svcs.network.network.id
}

resource "google_compute_firewall" "shared-consul" {
  name    = "shared-allow-consul"
  network = module.gcp-vpc-shared-svcs.network_name

  allow {
    protocol = "tcp"
    ports    = ["8300", "8301", "9301", "8302", "8502", "8443", "20000", "30851"]
  }

  allow {
    protocol = "udp"
    ports    = ["8301", "8302", "9301"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
