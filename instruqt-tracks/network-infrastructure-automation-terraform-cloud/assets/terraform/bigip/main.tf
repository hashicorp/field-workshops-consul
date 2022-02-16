terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}
