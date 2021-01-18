output "azure_product_api_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}
