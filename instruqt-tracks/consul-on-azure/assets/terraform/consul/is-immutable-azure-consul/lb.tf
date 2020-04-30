resource "azurerm_public_ip" "consul" {
  name                = "consul-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.consul.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_lb" "consul" {
  name                = "consul-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.consul.name

  frontend_ip_configuration {
    name                 = "configuration"
    public_ip_address_id = azurerm_public_ip.consul.id
  }
}

resource "azurerm_lb_backend_address_pool" "consul" {
  resource_group_name = azurerm_resource_group.consul.name
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "consul" {
  resource_group_name = azurerm_resource_group.consul.name
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "consul-http"
  port                = 8500
}

resource "azurerm_lb_rule" "consul" {
  resource_group_name = azurerm_resource_group.consul.name
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8500
  frontend_ip_configuration_name = "configuration"
  probe_id = azurerm_lb_probe.consul.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.consul.id
}
