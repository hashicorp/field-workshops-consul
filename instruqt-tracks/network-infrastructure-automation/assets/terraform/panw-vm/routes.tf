resource "azurerm_route_table" "PAN_FW_RT_Trust" {
  name                = var.routeTableTrust
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  route {
    name           = "routeToTrust"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.3.1.5"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "PAN_FW_RT_App" {
  name                = "routeToApp"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  route {
    name           = "routeToApp"
    address_prefix = "10.3.2.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.3.2.5"
  }

  route {
    name           = "Web-default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.3.2.5"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "PAN_FW_RT_DMZ" {
  name                = "routeToDmz"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  route {
    name           = "DMZ-to-Firewall-Web"
    address_prefix = "10.3.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.3.1.5"
  }

  route {
    name                   = "DMZ-default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.3.1.5"
  }

  tags =  {
    environment = "Production"
  }
}

#resource "azurerm_subnet_route_table_association" "example2" {
#  subnet_id                 = azurerm_subnet.app_subnet.id
#  route_table_id            = azurerm_route_table.PAN_FW_RT_Trust.id
#}