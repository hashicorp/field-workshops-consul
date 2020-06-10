provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "/root/terraform/vnet/terraform.tfstate"
  }
}

resource "azurerm_public_ip" "gateway" {
  name                = "gateway-ip"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "gateway"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false

  sku           = "Basic"
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[1]
  }

}


resource "azurerm_virtual_network_peering" "shared-frontend" {
  name                         = "SharedToFrontend"
  resource_group_name          = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name         = "shared-svcs-vnet"
  remote_virtual_network_id    = data.terraform_remote_state.vnet.outputs.frontend_vnet
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "shared-backend" {
  name                         = "SharedToBackend"
  resource_group_name          = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name         = "shared-svcs-vnet"
  remote_virtual_network_id    = data.terraform_remote_state.vnet.outputs.backend_vnet
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}


resource "azurerm_virtual_network_peering" "frontend-shared" {
  name                         = "FrontendToShared"
  resource_group_name          = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name         = "frontend-vnet"
  remote_virtual_network_id    = data.terraform_remote_state.vnet.outputs.shared_svcs_vnet
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  use_remote_gateways = var.remote_gateways
}

resource "azurerm_virtual_network_peering" "backend-shared" {
  name                         = "BackendToShared"
  resource_group_name          = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name         = "backend-vnet"
  remote_virtual_network_id    = data.terraform_remote_state.vnet.outputs.shared_svcs_vnet
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  use_remote_gateways = var.remote_gateways
}


resource "azurerm_route_table" "frontend" {
  name                          = "frontend-shared-aks"
  location                      = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name           = data.terraform_remote_state.vnet.outputs.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "backend"
    address_prefix = "10.3.0.0/16"
    next_hop_type  = "VirtualNetworkGateway"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "frontend" {
  subnet_id      = data.terraform_remote_state.vnet.outputs.frontend_subnets[0]
  route_table_id = azurerm_route_table.frontend.id
}

resource "azurerm_route_table" "backend" {
  name                          = "backend-shared-aks"
  location                      = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name           = data.terraform_remote_state.vnet.outputs.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "frontend"
    address_prefix = "10.2.0.0/16"
    next_hop_type  = "VirtualNetworkGateway"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "backend" {
  subnet_id      = data.terraform_remote_state.vnet.outputs.backend_subnets[0]
  route_table_id = azurerm_route_table.backend.id
}
