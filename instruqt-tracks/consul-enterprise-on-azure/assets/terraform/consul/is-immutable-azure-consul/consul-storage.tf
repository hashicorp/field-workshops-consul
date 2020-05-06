///////////////////
// Storage
///////////////////

resource "azurerm_storage_account" "cluster_data" {
  name                      = replace(random_id.environment_name.hex, "-", "")
  resource_group_name       = azurerm_resource_group.consul.name
  location                  = var.region
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = var.storage_account_type
  enable_https_traffic_only = true

  identity {
    type = "SystemAssigned"
  }
}