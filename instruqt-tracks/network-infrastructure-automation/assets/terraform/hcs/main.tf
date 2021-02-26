provider "azurerm" {
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

data "hcs_plan_defaults" "hcs_plan" {}

resource "azurerm_marketplace_agreement" "hcs_marketplace_agreement" {
  publisher = data.hcs_plan_defaults.hcs_plan.publisher
  offer     = data.hcs_plan_defaults.hcs_plan.offer
  plan      = data.hcs_plan_defaults.hcs_plan.plan_name
}

resource "hcs_cluster" "hcs" {
  resource_group_name      = data.terraform_remote_state.vnet.outputs.resource_group_name
  managed_application_name = "hcs"
  email                    = "instruqt@hashicorp.com"
  cluster_mode             = "Development"
  vnet_cidr                = "10.0.0.0/24"
  location                 = "eastus"
  consul_datacenter        = "east-us"
  consul_external_endpoint = true
  plan_name                = azurerm_marketplace_agreement.hcs_marketplace_agreement.plan
}

resource "azurerm_virtual_network_peering" "hcs-app" {
  name                      = "hcs-to-app"
  resource_group_name       = hcs_cluster.hcs.vnet_resource_group_name
  virtual_network_name      = hcs_cluster.hcs.vnet_name
  remote_virtual_network_id = data.terraform_remote_state.vnet.outputs.app_vnet
}

resource "azurerm_virtual_network_peering" "app-hcs" {
  name                      = "app-to-hcs"
  resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name      = "app-vnet"
  remote_virtual_network_id = hcs_cluster.hcs.vnet_id
}
