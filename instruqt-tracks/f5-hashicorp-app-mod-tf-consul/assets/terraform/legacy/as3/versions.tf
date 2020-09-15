terraform {
  required_providers {
    bigip = {
      source = "f5networks/bigip"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
