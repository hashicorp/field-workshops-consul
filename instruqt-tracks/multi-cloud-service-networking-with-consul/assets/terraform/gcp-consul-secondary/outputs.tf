# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "gcp_gke_cluster_shared_name" {
  value = google_container_cluster.shared.name
}
