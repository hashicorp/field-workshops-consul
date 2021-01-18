resource "random_password" "pg" {
  length           = 20
  special          = true
  override_special = "!@#%"
}

resource "azurerm_postgresql_server" "postgres" {
  name                = data.terraform_remote_state.infra.outputs.env
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  administrator_login          = "postgres"
  administrator_login_password = random_password.pg.result

  sku_name   = "GP_Gen5_4"
  version    = "9.6"
  storage_mb = 5120

  public_network_access_enabled = true
  ssl_enforcement_enabled       = false
}

resource "azurerm_postgresql_firewall_rule" "postgres" {
  name                = "AllowAll"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  server_name         = azurerm_postgresql_server.postgres.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
