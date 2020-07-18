data "terraform_remote_state" "bigip" {
  backend = "local"

  config = {
    path = "../../bigip/terraform.tfstate"
  }
}


data "terraform_remote_state" "hcs" {
  backend = "local"

  config = {
    path = "../../hcs/terraform.tfstate"
  }
}

provider "bigip" {
  address  = data.terraform_remote_state.bigip.outputs.mgmt_ip
  port     = 8443
  username = data.terraform_remote_state.bigip.outputs.username
  password = data.terraform_remote_state.bigip.outputs.admin_password
}

data "template_file" "virtualserverAS3" {
  template = file("${path.module}/templates/as3_declaration.json")
  vars = {
    vip_address = data.terraform_remote_state.bigip.outputs.vip_internal_address
    consul_url  = data.terraform_remote_state.hcs.outputs.consul_url
  }
}

resource "bigip_as3" "legacy-app" {
  as3_json = data.template_file.virtualserverAS3.rendered
}