terraform {
  required_providers {
    panos = {
      source = "PaloAltoNetworks/panos"
      version = "1.10.3"
    }
  }
}

data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "../01-deploy-infra/terraform.tfstate"
  }
}


provider "panos" {
  hostname = data.terraform_remote_state.environment.outputs.paloalto_mgmt_ip
  username = data.terraform_remote_state.environment.outputs.pa_username
  password = data.terraform_remote_state.environment.outputs.pa_password
}

module "pan-config" {
  source = "./pan-config"
}

module "vault" {
  source = "./vault"
}


resource "null_resource" "pan" {
  depends_on = [module.pan-config]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "/root/terraform/02-configure-infra/panos_commit/panos-commit -config /root/terraform/02-configure-infra/panos_commit/panos-commit/panos-commit.json -force"
  }
}

