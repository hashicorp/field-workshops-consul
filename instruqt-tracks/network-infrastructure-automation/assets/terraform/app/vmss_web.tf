# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name = "web-vmss"

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name


  upgrade_mode = "Manual"

  sku                 = "Standard_DS1_v2"
  instances           = var.web_count

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    lun                  = 0
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  computer_name_prefix = "web-vm-"
  admin_username       = "azure-user"
  custom_data          = base64encode(templatefile("./templates/web_server.sh", { consul_server_ip = var.consul_server_ip, bigip_mgmt_addr = var.bigip_mgmt_addr, vip_internal_address = var.vip_internal_address }))

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure-user"
    public_key = var.ssh_public_key
  }

  network_interface {
    name                      = "web-vms-netprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.webserver-sg.id
    ip_configuration {
      name      = "Web-IPConfiguration"
      subnet_id = data.terraform_remote_state.vnet.outputs.app_subnet
      primary   = true
    }
  }
  
  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_network_security_group" "webserver-sg" {
  name                = "webserver-security-group"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

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

}
