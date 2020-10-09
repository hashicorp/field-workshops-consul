provider "azurerm" {
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}

resource "random_string" "storageaccountname" {
  length  = 13
  upper   = false
  lower   = true
  special = false
}

resource "random_string" "blobcontainername" {
  length  = 13
  upper   = false
  lower   = true
  special = false
}

resource "azurerm_marketplace_agreement" "hcs" {
  publisher = "hashicorp-4665790"
  offer     = "hcs-production"
  plan      = "on-demand-v2"
}

resource "azurerm_managed_application" "hcs" {
  depends_on = [azurerm_marketplace_agreement.hcs]

  name                        = "hcs"
  location                    = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name         = data.terraform_remote_state.vnet.outputs.resource_group_name
  kind                        = "MarketPlace"
  managed_resource_group_name = "${data.terraform_remote_state.vnet.outputs.resource_group_name}-mrg-hcs"

  plan {
    name      = "on-demand-v2"
    product   = "hcs-production"
    publisher = "hashicorp-4665790"
    version   = "0.0.46"
  }

  parameters = {
    initialConsulVersion  = "v1.8.0"
    storageAccountName    = "${random_string.storageaccountname.result}"
    blobContainerName     = "${random_string.blobcontainername.result}"
    clusterMode           = "DEVELOPMENT"
    clusterName           = "hashicorp-consul-cluster"
    consulDataCenter      = "east-us"
    numServers            = "1"
    numServersDevelopment = "1"
    automaticUpgrades     = "disabled"
    consulConnect         = "enabled"
    externalEndpoint      = "enabled"
    snapshotInterval      = "1d"
    snapshotRetention     = "1m"
    consulVnetCidr        = "10.0.0.0/24"
    location              = data.terraform_remote_state.vnet.outputs.resource_group_location
    providerBaseURL       = "https://ama-api.hashicorp.cloud/consulama/2020-09-09"
    email                 = "instruqt@hashicorp.com"
  }
}

data "azurerm_virtual_network" "hcs" {
  depends_on          = [azurerm_managed_application.hcs]
  name                = "${lookup(azurerm_managed_application.hcs.outputs, "vnet_name")}-vnet"
  resource_group_name = "${data.terraform_remote_state.vnet.outputs.resource_group_name}-mrg-hcs"
}

resource "azurerm_virtual_network_peering" "hcs-legacy" {
  depends_on                = [azurerm_managed_application.hcs]
  name                      = "HCSToLegacy"
  resource_group_name       = "${data.terraform_remote_state.vnet.outputs.resource_group_name}-mrg-hcs"
  virtual_network_name      = "${lookup(azurerm_managed_application.hcs.outputs, "vnet_name")}-vnet"
  remote_virtual_network_id = data.terraform_remote_state.vnet.outputs.legacy_vnet
}

resource "azurerm_virtual_network_peering" "legacy-hcs" {
  depends_on                = [azurerm_managed_application.hcs]
  name                      = "LegacyToHCS"
  resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name      = "legacy-vnet"
  remote_virtual_network_id = data.azurerm_virtual_network.hcs.id
}

resource "azurerm_virtual_network_peering" "hcs-aks" {
  depends_on                = [azurerm_managed_application.hcs]
  name                      = "HCSToAKS"
  resource_group_name       = "${data.terraform_remote_state.vnet.outputs.resource_group_name}-mrg-hcs"
  virtual_network_name      = "${lookup(azurerm_managed_application.hcs.outputs, "vnet_name")}-vnet"
  remote_virtual_network_id = data.terraform_remote_state.vnet.outputs.aks_vnet
}

resource "azurerm_virtual_network_peering" "aks-hcs" {
  depends_on                = [azurerm_managed_application.hcs]
  name                      = "AKSToHCS"
  resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name
  virtual_network_name      = "aks-vnet"
  remote_virtual_network_id = data.azurerm_virtual_network.hcs.id
}
