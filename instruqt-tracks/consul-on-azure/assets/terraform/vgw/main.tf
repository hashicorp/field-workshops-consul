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
    subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[2]
  }

}
