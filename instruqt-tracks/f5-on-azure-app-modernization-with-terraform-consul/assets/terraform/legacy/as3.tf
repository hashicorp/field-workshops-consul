resource "null_resource" "virtualserverAS3" {
  provisioner "local-exec" {
    command = <<-EOT
        sleep 120 
        curl -s -k -X POST https://${azurerm_public_ip.sip_public_ip.ip_address}:8443/mgmt/shared/appsvcs/declare \
              -H 'Content-Type: application/json' \
              --max-time 600 \
              --retry 10 \
              --retry-delay 30 \
              --retry-max-time 600 \
              -u "admin:${random_password.bigippassword.result}" \
              -d '${data.template_file.virtualserverAS3.rendered}'
        EOT
  }

  depends_on = [
    azurerm_linux_virtual_machine.f5bigip,
    azurerm_virtual_machine_extension.run_startup_cmd,
  ]

  triggers = {
    as3_content = data.template_file.virtualserverAS3.rendered
  }
}

data "template_file" "virtualserverAS3" {
  template = file("${path.module}/templates/web.json")
  vars = {
    vip_address = azurerm_network_interface.ext-nic.private_ip_address
  }
}
