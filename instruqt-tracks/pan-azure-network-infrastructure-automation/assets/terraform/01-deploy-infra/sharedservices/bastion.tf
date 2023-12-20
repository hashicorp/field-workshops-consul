# Deploy bastion

resource "random_string" "bastionparticipant" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}
resource "azurerm_public_ip" "bastion" {
  name                = "bastion-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "bastion" {
  name                = "bastion-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "bastionconfiguration"
    subnet_id                     = var.boundary_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "bastion" {
  name                = "bastion-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "bastionconfiguration"
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_lb_backend_address_pool" "bastion" {
  loadbalancer_id = azurerm_lb.bastion.id
  name            = "bastionBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "bastion" {
  network_interface_id    = azurerm_network_interface.bastion.id
  ip_configuration_name   = "bastionconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bastion.id
}

resource "azurerm_lb_probe" "bastion" {
  loadbalancer_id = azurerm_lb.bastion.id
  name            = "bastion-http"
  port            = 22
}

resource "azurerm_lb_rule" "bastion" {
  loadbalancer_id                = azurerm_lb.bastion.id
  name                           = "bastion"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "bastionconfiguration"
  probe_id                       = azurerm_lb_probe.bastion.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bastion.id]
}


resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "bastion-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "bastionmyOsDisk${random_string.bastionparticipant.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  # custom_data = base64encode(file("${path.module}/scripts/logging.sh", { 
  #   consul_server_ip = "${azurerm_network_interface.consul.private_ip_address}",
  #   CONSUL_VERSION = "1.12.2",
  # }))

  computer_name                   = "bastion-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.bastion.public_key_openssh
  }

  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_security_group" "bastion" {
  name                = "bastion-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

   security_rule {
    name                       = "SSH-22"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
    depends_on = [
    azurerm_linux_virtual_machine.bastion
  ]
}


## SSH Key 

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "bastion" {
  name                = "bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.bastion.public_key_openssh
}

resource "null_resource" "bastionkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.bastion.private_key_pem}\" > ${azurerm_ssh_public_key.bastion.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}

