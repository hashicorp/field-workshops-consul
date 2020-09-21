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

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "./iam/terraform.tfstate"
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

data "terraform_remote_state" "vault" {
  backend = "local"

  config = {
    path = "../vault/terraform.tfstate"
  }
}
