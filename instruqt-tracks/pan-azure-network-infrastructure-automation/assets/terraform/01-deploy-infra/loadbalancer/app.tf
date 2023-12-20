
resource "azurerm_lb" "app" {
  name                = "app-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "appconfiguration"
    subnet_id = var.app_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "appBackEndAddressPool"
}

resource "azurerm_lb_probe" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "app-http"
  port            = 9094
}

resource "azurerm_lb_rule" "app" {
  loadbalancer_id                = azurerm_lb.app.id
  name                           = "app"
  protocol                       = "Tcp"
  frontend_port                  = 9094
  backend_port                   = 9094
  frontend_ip_configuration_name = "appconfiguration"
  probe_id                       = azurerm_lb_probe.app.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
}
