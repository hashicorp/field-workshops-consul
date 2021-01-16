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

data "terraform_remote_state" "bigip" {
  backend = "local"

  config = {
    path = "../bigip/terraform.tfstate"
  }
}

data "terraform_remote_state" "hcs" {
  backend = "local"

  config = {
    path = "../hcs/terraform.tfstate"
  }
}
