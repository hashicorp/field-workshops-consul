resource "google_service_account" "consul" {
  account_id   = "consul-${data.terraform_remote_state.infra.outputs.env}"
  display_name = "consul-${data.terraform_remote_state.infra.outputs.env}"
}

resource "google_project_iam_binding" "reader_binding" {
  role = "roles/compute.viewer"

  members = [
    "serviceAccount:${google_service_account.consul.email}",
  ]
}

resource "google_project_iam_binding" "token_creater_binding" {
  role = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.consul.email}",
  ]
}
