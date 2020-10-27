output "gcp_consul_public_ip" {
  value = google_compute_address.static.address
}

output "gcp_mgw_public_ip" {
  value = google_compute_address.mgw.address
}

output "azure_consul_public_ip" {
  value = azurerm_public_ip.consul.ip_address
}

output "azure_mgw_public_ip" {
  value = azurerm_public_ip.mgw.ip_address
}

output "gcp_internal_consul_dns" {
  value = "consul.consul-ilb.il4.us-central1.lb.${var.gcp_project_id}.internal"
}
