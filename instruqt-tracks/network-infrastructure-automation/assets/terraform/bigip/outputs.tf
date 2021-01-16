output "mgmt_url" {
  value = "https://${azurerm_public_ip.sip_public_ip.ip_address}:8443/"
}

output "mgmt_ip" {
#  value = azurerm_network_interface.dmz-nic.private_ip_address
  value = azurerm_public_ip.sip_public_ip.ip_address
}

output "app_url" {
  value = "http://${azurerm_public_ip.sip_public_ip.ip_address}/"
}

output "f5_username" {
  value = var.admin_username
}

output "f5_password" {
  value = random_password.bigippassword.result
}

output "vip_internal_address" {
  value = azurerm_network_interface.dmz-nic.private_ip_address
}
