output "gcp_consul_public_ip" {
  value = google_compute_address.static.address
}

output "gcp_mgw_public_ip" {
  value = google_compute_address.mgw.address
}
