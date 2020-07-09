resource "null_resource" "virtualserverAS3" {
  provisioner "local-exec" {
    command = <<-EOT
        sleep 120 
        curl -s -k -X POST ${data.terraform_remote_state.bigip.outputs.mgmt_url}/mgmt/shared/appsvcs/declare \
              -H 'Content-Type: application/json' \
              --max-time 600 \
              --retry 10 \
              --retry-delay 30 \
              --retry-max-time 600 \
              -u "${data.terraform_remote_state.bigip.outputs.username}:${data.terraform_remote_state.bigip.outputs.admin_password}" \
              -d '${data.template_file.virtualserverAS3.rendered}'
        EOT
  }

  triggers = {
    as3_content = data.template_file.virtualserverAS3.rendered
  }
}

data "template_file" "virtualserverAS3" {
  template = file("${path.module}/templates/as3_definition.json")
  vars = {
    vip_address = data.terraform_remote_state.bigip.outputs.vip_internal_address
    consul_url = data.terraform_remote_state.hcs.outputs.consul_url
  }
}
