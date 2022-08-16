resource "azurerm_linux_virtual_machine_scale_set" "db" {
  name                            = "db-vmss"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = "Standard_F2"
  instances                       = var.db_count
  admin_username                  = "adminuser"
  custom_data                     = base64encode(templatefile("${path.module}/scripts/fakeservice.sh", { 
    consul_server_ip = var.consul_server_ip,
    CONSUL_VERSION = "1.12.2" 
  }))

  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.db.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "db-vms-netprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.dbserver-sg.id

    ip_configuration {
      name      = "db-IPConfiguration"
      subnet_id = var.db_subnet
      primary   = true
      load_balancer_backend_address_pool_ids = [ var.db-id ]
    }
  }
}



resource "azurerm_network_security_group" "dbserver-sg" {
  name                = "dbserver-security-group"
  location                        = var.location
  resource_group_name             = var.resource_group_name

  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
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
    priority                   = 1002
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
    priority                   = 1003
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
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "db2"
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
    name                       = "db3"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9095"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
