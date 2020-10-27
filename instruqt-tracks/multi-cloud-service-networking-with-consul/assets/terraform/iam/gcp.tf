resource "google_service_account" "consul" {
  account_id   = "consul-${data.terraform_remote_state.infra.outputs.env}"
  display_name = "consul-${data.terraform_remote_state.infra.outputs.env}"
}

resource "google_project_iam_member" "reader_binding" {
  role = "roles/compute.viewer"
  member = "serviceAccount:${google_service_account.consul.email}"
}

resource "google_project_iam_member" "token_creater_binding" {
  role = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.consul.email}"
}
