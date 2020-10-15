resource "google_service_account" "consul" {
  account_id   = "consul-${data.terraform_remote_state.infra.outputs.env}"
  display_name = "consul-${data.terraform_remote_state.infra.outputs.env}"
}

resource "google_project_iam_member" "consul" {
  member = "serviceAccount:${google_service_account.consul.email}"
  role   = "roles/compute.viewer"
}
