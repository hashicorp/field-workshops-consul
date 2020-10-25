output "postgres_fqdn" {
  value = azurerm_postgresql_server.postgres.fqdn
}

output "postgres_password" {
  value = random_password.pg.result
}
