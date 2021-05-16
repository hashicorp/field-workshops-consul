terraform {
  required_providers {
    panos = {
      source  = "PaloAltoNetworks/panos"
      version = "1.6.3"
    }
  }
}

data "terraform_remote_state" "panw-vm" {
  backend = "local"

  config = {
    path = "../panw-vm/terraform.tfstate"
  }
}

provider "panos" {
  hostname = data.terraform_remote_state.panw-vm.outputs.FirewallIP
  username = data.terraform_remote_state.panw-vm.outputs.pa_username
  password = data.terraform_remote_state.panw-vm.outputs.pa_password
}

module "panos" {
  source = "./panos"
}

resource "null_resource" "panos_config" {
  depends_on = [module.panos]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "/root/terraform/panos_commit/panos-commit -config /root/terraform/panos_commit/panos-commit.json -force"
  }
}
