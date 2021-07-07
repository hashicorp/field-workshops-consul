resource "google_service_account" "consul" {
  account_id   = "consul-${data.terraform_remote_state.infra.outputs.env}"
  display_name = "consul"
}

resource "google_project_iam_member" "consul" {
  project = var.gcp_project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.consul.email}"
}
