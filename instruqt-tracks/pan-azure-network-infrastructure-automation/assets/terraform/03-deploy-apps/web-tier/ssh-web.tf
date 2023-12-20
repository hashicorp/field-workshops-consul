resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "web" {
  name                = "web"
  location            = "East US"
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.web.public_key_openssh
}

resource "null_resource" "webkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.web.private_key_pem}\" > ${azurerm_ssh_public_key.web.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}
