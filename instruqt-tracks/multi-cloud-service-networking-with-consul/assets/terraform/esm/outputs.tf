output "aws_esm_public_ip" {
  value = aws_instance.esm.public_ip
}

output "azure_esm_public_ip" {
  value = azurerm_public_ip.esm.ip_address
}
