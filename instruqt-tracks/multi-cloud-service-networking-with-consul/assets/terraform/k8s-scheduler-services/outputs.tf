output "gcp_gke_cluster_react_name" {
  value = google_container_cluster.react.name
}

output "gcp_gke_cluster_react_endpoint" {
  value = google_container_cluster.react.endpoint
}

output "gcp_gke_cluster_react_cluster_ca_certificate" {
  value = google_container_cluster.react.master_auth.0.cluster_ca_certificate
}

output "gcp_gke_cluster_graphql_name" {
  value = google_container_cluster.graphql.name
}

output "gcp_gke_cluster_graphql_endpoint" {
  value = google_container_cluster.graphql.endpoint
}

output "gcp_gke_cluster_graphql_cluster_ca_certificate" {
  value = google_container_cluster.graphql.master_auth.0.cluster_ca_certificate
}
