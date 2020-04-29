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
  consul_cluster_version = var.cluster_version
}
