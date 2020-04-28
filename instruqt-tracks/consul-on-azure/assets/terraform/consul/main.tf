provider "azurerm" {
  version = "=2.0.0"
  features {}
}

module "consul" {
  source = "./is-immutable-aws-consul"

  region = "eastus"
  subnet_id = "test"
  ssh_public_key = "test"
  owner = "instruqt"
  ttl   = "-1"
  image_resource_group = "test"
}
