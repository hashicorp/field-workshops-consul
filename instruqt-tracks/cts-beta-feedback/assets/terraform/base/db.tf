resource "azurerm_virtual_machine_scale_set" "db_vmss" {
  name = "db-vmss"

  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  upgrade_policy_mode = "Manual"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.db.id]
  }

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = var.db_count
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "db-vm-"
    admin_username       = "azure-user"
    custom_data          = base64encode(templatefile(
      "./templates/db_server.sh", 
      { 
        consul_datacenter = "east-us"
      }
    ))
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }

  }

  network_profile {
    name                      = "db-vms-netprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.webserver-sg.id
    ip_configuration {
      name      = "db-IPConfiguration"
      subnet_id = module.network.vnet_subnets[1]
      primary   = true
    }
  }
}

resource "azurerm_network_security_group" "db-sg" {
  name                = "webserver-security-group"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

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
    name                       = "db"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9091"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}