resource "azurerm_route_table" "web-route-to-fw" {
  name                = "web-route-to-fw"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "web-route-to-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.1.1.5"
  }


  tags = {
    environment = "Production"
  }
}


resource "azurerm_subnet_route_table_association" "web" {
 subnet_id                 = var.web_subnet
 route_table_id            = azurerm_route_table.web-route-to-fw.id
}



resource "azurerm_route_table" "app-route-to-fw" {
  name                = "app-route-to-fw"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "app-route-to-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.1.1.5"
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_subnet_route_table_association" "app" {
 subnet_id                 = var.app_subnet
 route_table_id            = azurerm_route_table.app-route-to-fw.id
}



resource "azurerm_route_table" "db-route-to-fw" {
  name                = "db-route-to-fw"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "db-route-to-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.1.1.5"
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_subnet_route_table_association" "db" {
 subnet_id                 = var.db_subnet
 route_table_id            = azurerm_route_table.db-route-to-fw.id
}



resource "azurerm_route_table" "shared-route-to-fw" {
  name                = "shared-route-to-fw"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "shared-route-to-fw"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.1.1.5"
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_subnet_route_table_association" "shared" {
 subnet_id                 = var.consul_subnet
 route_table_id            = azurerm_route_table.shared-route-to-fw.id
}


resource "azurerm_subnet_route_table_association" "boundary" {
 subnet_id                 = var.boundary_subnet
 route_table_id            = azurerm_route_table.shared-route-to-fw.id
}


resource "azurerm_subnet_route_table_association" "vault" {
 subnet_id                 = var.vault_subnet
 route_table_id            = azurerm_route_table.shared-route-to-fw.id
}
