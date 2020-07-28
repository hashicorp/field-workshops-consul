provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  dns_prefix          = "aks"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = data.terraform_remote_state.vnet.outputs.aks_subnets[0]
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
