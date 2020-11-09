resource "google_compute_firewall" "shared-connect" {
  name    = "shared-allow-connect"
  network = "vpc-shared-svcs"

  allow {
    protocol = "tcp"
    ports    = ["20000", "8443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["consul-connect"]
}

resource "google_compute_firewall" "app-connect" {
  name    = "app-allow-connect"
  network = "vpc-app"

  allow {
    protocol = "tcp"
    ports    = ["20000", "8443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["consul-connect"]
}
