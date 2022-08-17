# Deploy logging

resource "random_string" "loggingparticipant" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}
resource "azurerm_public_ip" "logging" {
  name                = "logging-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "logging" {
  name                = "logging-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "loggingconfiguration"
    subnet_id                     = var.boundary_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "logging" {
  name                = "logging-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "loggingconfiguration"
    public_ip_address_id = azurerm_public_ip.logging.id
  }
}

resource "azurerm_lb_backend_address_pool" "logging" {
  loadbalancer_id = azurerm_lb.logging.id
  name            = "loggingBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "logging" {
  network_interface_id    = azurerm_network_interface.logging.id
  ip_configuration_name   = "loggingconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.logging.id
}

resource "azurerm_lb_probe" "logging" {
  loadbalancer_id = azurerm_lb.logging.id
  name            = "logging-http"
  port            = 22
}

resource "azurerm_lb_rule" "logging" {
  loadbalancer_id                = azurerm_lb.logging.id
  name                           = "logging"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "loggingconfiguration"
  probe_id                       = azurerm_lb_probe.logging.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.logging.id]
}


resource "azurerm_linux_virtual_machine" "logging" {
  name                  = "logging-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.logging.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "loggingnmyOsDisk${random_string.loggingparticipant.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data = base64encode(templatefile("${path.module}/scripts/logging.sh", { 
    consul_server_ip = azurerm_network_interface.consul.private_ip_address,
    CONSUL_VERSION = "1.12.2" 
  }))

  computer_name                   = "logging-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.logging.public_key_openssh
  }

  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_security_group" "logging" {
  name                = "logging-nsg"
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
   security_rule {
    name                       = "LOGGING"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "5140"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "logging" {
  network_interface_id      = azurerm_network_interface.logging.id
  network_security_group_id = azurerm_network_security_group.logging.id
    depends_on = [
    azurerm_linux_virtual_machine.logging
  ]
}


## SSH Key 

resource "tls_private_key" "logging" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "logging" {
  name                = "logging"
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.logging.public_key_openssh
}

resource "null_resource" "loggingkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.logging.private_key_pem}\" > ${azurerm_ssh_public_key.logging.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}

