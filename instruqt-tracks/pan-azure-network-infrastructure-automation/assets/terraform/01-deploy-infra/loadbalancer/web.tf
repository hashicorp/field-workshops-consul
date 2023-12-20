
resource "azurerm_lb" "web" {
  name                = "web-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "webconfiguration"
    subnet_id = var.web_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "webBackEndAddressPool"
}

resource "azurerm_lb_probe" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "web-http"
  port            = 9090
}

resource "azurerm_lb_rule" "web" {
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "web"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 9090
  frontend_ip_configuration_name = "webconfiguration"
  probe_id                       = azurerm_lb_probe.web.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
}
