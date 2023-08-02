# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "google_container_engine_versions" "shared" {
  project        = var.gcp_project_id
  location       = "us-central1-a"
  version_prefix = "1.23.17-gke."
}

resource "google_container_cluster" "shared" {
  project            = var.gcp_project_id
  name               = "shared-${data.terraform_remote_state.infra.outputs.env}"
  location           = "us-central1-a"
  initial_node_count = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  network    = "vpc-shared-svcs"
  subnetwork = "shared"

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # IL-798 At creation the node_version must be set to the same as
  # min_master_version, so use the same setting for both instead of
  # `latest_node_version` from the data source
  min_master_version = data.google_container_engine_versions.shared.latest_master_version
  node_version       = data.google_container_engine_versions.shared.latest_master_version

  # GKE mandates at least 48hr of maintenance window in a 32 day period.
  # We don't want upgrades during a lab, so we use the below values.
  # Choose two six-hour windows on Saturday and Sunday.
  # The earliest maintenance would start would be on a Saturday at 3am
  # in Honolulu, the latest would be Monday 4am in Tokyo, to pick locales
  # roughly at either end of time zone offsets
  maintenance_policy {
    recurring_window {
      start_time = "2022-12-11T13:00:00Z"
      end_time   = "2022-12-11T19:00:00Z"
      recurrence = "FREQ=WEEKLY;WKST=SU;BYDAY=SA,SU"
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
