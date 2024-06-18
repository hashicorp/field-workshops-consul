# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_password" "pg" {
  length           = 20
  special          = true
  override_special = "!@#%"
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "instruqt-${data.terraform_remote_state.infra.outputs.env}"
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  version                = "13"
  administrator_login    = "postgres"
  administrator_password = random_password.pg.result
  zone                   = "1"

  storage_mb = 32768
  sku_name   = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "PGCRYPTO"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
