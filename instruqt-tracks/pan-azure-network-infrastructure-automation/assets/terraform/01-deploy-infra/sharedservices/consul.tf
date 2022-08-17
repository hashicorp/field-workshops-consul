# Deploy Consul

resource "random_string" "consulparticipant" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}
resource "azurerm_public_ip" "consul" {
  name                = "consul-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "consul" {
  name                = "consul-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "consulconfiguration"
    subnet_id                     = var.consul_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "consul" {
  name                = "consul-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "consulconfiguration"
    public_ip_address_id = azurerm_public_ip.consul.id
  }
}

resource "azurerm_lb_backend_address_pool" "consul" {
  loadbalancer_id = azurerm_lb.consul.id
  name            = "consulBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "consul" {
  network_interface_id    = azurerm_network_interface.consul.id
  ip_configuration_name   = "consulconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.consul.id
}

resource "azurerm_lb_probe" "consul" {
  loadbalancer_id = azurerm_lb.consul.id
  name            = "consul-http"
  port            = 8500
}

resource "azurerm_lb_rule" "consul" {
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8500
  frontend_ip_configuration_name = "consulconfiguration"
  probe_id                       = azurerm_lb_probe.consul.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.consul.id]
}


resource "azurerm_linux_virtual_machine" "consul" {
  name                  = "consul-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.consul.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "consulmyOsDisk${random_string.consulparticipant.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data = base64encode(file("${path.module}/scripts/consul.sh"))

  computer_name                   = "consul-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.consul.public_key_openssh
  }

  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_security_group" "consul" {
  name                = "consul-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

   security_rule {
    name                       = "HTTPS-80"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS-8500"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RPC"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8300"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Serf"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8301"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "app"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9091"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web2"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9094"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "app3"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "juiceshop1"
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
security_rule {
    name                       = "cts"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8558"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "LOGGING"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "5140"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "consul" {
  network_interface_id      = azurerm_network_interface.consul.id
  network_security_group_id = azurerm_network_security_group.consul.id
    depends_on = [
    azurerm_linux_virtual_machine.consul
  ]
}


## SSH Key 

resource "tls_private_key" "consul" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "consul" {
  name                = "consul"
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.consul.public_key_openssh
}

resource "null_resource" "consulkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.consul.private_key_pem}\" > ${azurerm_ssh_public_key.consul.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}

