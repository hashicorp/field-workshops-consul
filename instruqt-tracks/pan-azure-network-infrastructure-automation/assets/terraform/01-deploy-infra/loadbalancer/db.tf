
resource "azurerm_lb" "db" {
  name                = "db-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "dbconfiguration"
    subnet_id = var.db_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "db" {
  loadbalancer_id = azurerm_lb.db.id
  name            = "dbBackEndAddressPool"
}

resource "azurerm_lb_probe" "db" {
  loadbalancer_id = azurerm_lb.db.id
  name            = "db-http"
  port            = 9095
}

resource "azurerm_lb_rule" "db" {
  loadbalancer_id                = azurerm_lb.db.id
  name                           = "db"
  protocol                       = "Tcp"
  frontend_port                  = 9095
  backend_port                   = 9095
  frontend_ip_configuration_name = "dbconfiguration"
  probe_id                       = azurerm_lb_probe.db.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.db.id]
}
