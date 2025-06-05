resource "tls_private_key" "app" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "app" {
  name                = "app"
  location            = "East US"
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.app.public_key_openssh
}

resource "null_resource" "appkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.app.private_key_pem}\" > ${azurerm_ssh_public_key.app.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}
