resource "google_container_cluster" "shared" {
  provider           = google-beta
  project            = var.gcp_project_id
  name               = "shared-${data.terraform_remote_state.infra.outputs.env}"
  location           = "us-central1-a"
  initial_node_count = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  network    = "vpc-shared-svcs"
  subnetwork = "shared"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    service_account = data.terraform_remote_state.iam.outputs.gcp_consul_service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = "n1-standard-2"
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["consul-server", "consul-connect"]
  }

  enable_legacy_abac = true

  timeouts {
    create = "30m"
    update = "40m"
  }
}
