output "mgmt_url" {
  value = "https://${azurerm_public_ip.sip_public_ip.ip_address}:8443/"
}

output "mgmt_ip" {
  value = azurerm_public_ip.sip_public_ip.ip_address
}

output "app_url" {
  value = "http://${azurerm_public_ip.sip_public_ip.ip_address}:8080/"
}

output "username" {
  value = var.admin_username
}

output "admin_password" {
  value = random_password.bigippassword.result
}

output "vip_internal_address" {
  value = azurerm_network_interface.ext-nic.private_ip_address
}

output "ambassador_url" {
  value = "https://${azurerm_public_ip.sip_public_ip.ip_address}"
}
