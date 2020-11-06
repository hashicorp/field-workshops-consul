output "aws_nomad_server_public_ip" {
  value = aws_instance.nomad.public_ip
}

output "gcp_gke_cluster_react_name" {
  value = google_container_cluster.react.name
}

output "gcp_gke_cluster_graphql_name" {
  value = google_container_cluster.graphql.name
}
