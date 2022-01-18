output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_password" {
  value = random_password.pg.result
}
