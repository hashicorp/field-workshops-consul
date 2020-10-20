resource "google_container_cluster" "k8s" {
  name               = data.terraform_remote_state.infra.outputs.env
  location           = "us-central1-a"
  initial_node_count = 2

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
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
