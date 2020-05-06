provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "azurerm_subscription" "current" {}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "/root/terraform/vnet/terraform.tfstate"
  }
}

module "consul" {
  source = "./is-immutable-azure-consul"

  region         = var.location
  subnet_id      = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[0]
  ssh_public_key = var.ssh_public_key

  owner = "instruqt"
  ttl   = "-1"

  image_resource_group = var.image_resource_group
  image_prefix         = "is-azure-immutable-consul"

  consul_nodes   = 3
  enable_connect = true

  consul_vm_size       = "Standard_D2_v2"
  vm_managed_disk_type = "Standard_LRS"

  bootstrap              = var.bootstrap
  consul_cluster_version = var.consul_cluster_version
}

resource "azurerm_network_security_group" "consul" {
  name                = "consul-nsg"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  security_rule {
    name                       = "AllowConsulApiInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "consul" {
  subnet_id                 = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[0]
  network_security_group_id = azurerm_network_security_group.consul.id
}

/*
resource "null_resource" "consul-upgrade" {
  depends_on = [module.consul]
  provisioner "local-exec" {
    command = "azure-cluster-upgrade -r ${module.consul.consul_rg} -v ${module.consul.consul_vmss} -s ${data.azurerm_subscription.current.subscription_id}"
  }
}
*/
