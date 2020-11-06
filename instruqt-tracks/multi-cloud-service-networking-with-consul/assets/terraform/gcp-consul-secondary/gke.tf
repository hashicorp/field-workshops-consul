resource "google_container_cluster" "shared" {
  name               = "shared-${data.terraform_remote_state.infra.outputs.env}"
  location           = "us-central1-a"
  initial_node_count = 1

  network = "vpc-shared-svcs"
  subnetwork = "shared"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["consul-server"]
  }

  enable_legacy_abac = true

  timeouts {
    create = "30m"
    update = "40m"
  }
}
