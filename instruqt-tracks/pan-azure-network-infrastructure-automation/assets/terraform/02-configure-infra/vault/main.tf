terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.7.0"
    }
  }
}

data "terraform_remote_state" "build-infra" {
  backend = "local"

  config = {
    path = "../01-deploy-infra/terraform.tfstate"
  }
}



provider "vault" {
    address = data.terraform_remote_state.build-infra.outputs.vault_lb
    token = "root"
}

resource "vault_mount" "infrastructure" {
  path        = "net_infra"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "net_infra" {
  mount                      = vault_mount.infrastructure.path
  name                       = "paloalto"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    panpassword       =  data.terraform_remote_state.build-infra.outputs.pa_password,
    username       =  data.terraform_remote_state.build-infra.outputs.pa_username

  }
  )
}



