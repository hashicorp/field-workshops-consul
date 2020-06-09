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

resource "azurerm_kubernetes_cluster" "frontend" {
  name                = "frontend-aks"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  dns_prefix          = "frontend"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = data.terraform_remote_state.vnet.outputs.frontend_subnets[0]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  service_principal {
    client_id     = "msi"
    client_secret = "msi"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_kubernetes_cluster" "backend" {
  name                = "backend-aks"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  dns_prefix          = "backend"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = data.terraform_remote_state.vnet.outputs.backend_subnets[0]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  service_principal {
    client_id     = "msi"
    client_secret = "msi"
  }

  tags = {
    Environment = "Production"
  }
}
