data "azurerm_client_config" "current" {}

data "azurerm_image" "hashitools" {
  name_regex          = "${var.image_prefix}.*"
  resource_group_name = var.image_resource_group
  sort_descending     = true
}

resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = "${var.name_prefix}-"
}
