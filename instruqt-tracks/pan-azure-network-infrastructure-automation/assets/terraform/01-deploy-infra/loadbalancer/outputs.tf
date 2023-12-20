
output "web-lb" {
  value = azurerm_lb.web.private_ip_address
}
output "web-id" {
  value = azurerm_lb_backend_address_pool.web.id
}

output "app-lb" {
  value = azurerm_lb.app.private_ip_address
}
output "app-id" {
  value = azurerm_lb_backend_address_pool.app.id
}


output "db-lb" {
  value = azurerm_lb.db.private_ip_address
}
output "db-id" {
  value = azurerm_lb_backend_address_pool.db.id
}