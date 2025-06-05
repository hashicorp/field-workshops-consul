

# resource "azurerm_route_table" "PAN_FW_RT_Web" {
#   name                = "routeToWeb"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   route {
#     name                   = "routeToWeb"
#     address_prefix         = "10.3.0.0/16"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.1.1.5"
#   }
#  route {
#     name                   = "routeToShared"
#     address_prefix         = "10.2.0.0/16"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.1.1.5"
#   }
#   route {
#     name                   = "default-route"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.1.0.5"
#   }

#   tags = {
#     environment = "Production"
#   }
# }

# resource "azurerm_route_table" "PAN_FW_RT_DMZ" {
#   name                = "routeToDmz"
#   location            = var.resourcelocation
#   resource_group_name = var.resourcename

#   route {
#     name                   = "DMZ-to-Firewall-Web"
#     address_prefix         = "10.3.1.0/24"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.3.1.5"
#   }

#   route {
#     name                   = "DMZ-default-route"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.3.1.5"
#   }

#   tags = {
#     environment = "Production"
#   }
# }



#resource "azurerm_subnet_route_table_association" "example2" {
#  subnet_id                 = azurerm_subnet.app_subnet.id
#  route_table_id            = azurerm_route_table.PAN_FW_RT_Trust.id
#}