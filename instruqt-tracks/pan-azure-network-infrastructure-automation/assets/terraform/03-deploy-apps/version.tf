terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.25.0"
    }
  }
}

provider "azurerm" {
  features {}
}

