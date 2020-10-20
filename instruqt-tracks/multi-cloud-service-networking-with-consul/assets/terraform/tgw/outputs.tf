output "aws_tgw_public_ip" {
  value = aws_instance.tgw.public_ip
}

output "azure_tgw_public_ip" {
  value = azurerm_public_ip.tgw.ip_address
}
