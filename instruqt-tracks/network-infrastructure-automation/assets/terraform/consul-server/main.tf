# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  version = "=3.72.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "../vnet/terraform.tfstate"
  }
}


resource "azurerm_public_ip" "consul" {
  name                = "consul-ip"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "consul" {
    name                      = "consulserverNIC"
    location                  = data.terraform_remote_state.vnet.outputs.resource_group_location
    resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name

    ip_configuration {
        name                          = "consulserverNicConfiguration"
        subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[2]
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "Instruqt"
    }
  
  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_lb" "consul" {
  name                = "consul-lb"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "consulserverNicconfiguration"
    public_ip_address_id = azurerm_public_ip.consul.id
  }
  
  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_lb_backend_address_pool" "consul" {
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "consul" {
  network_interface_id    = azurerm_network_interface.consul.id
  ip_configuration_name   = "consulserverNicConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.consul.id
}

resource "azurerm_lb_probe" "consul-ssh" {
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "consul-ssh"
  port                = 22
}

resource "azurerm_lb_rule" "consul-ssh" {
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul-ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "consulserverNicconfiguration"
  probe_id                       = azurerm_lb_probe.consul.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.consul.id]
}

resource "azurerm_lb_probe" "consul" {
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "consul-http"
  port                = 8500
}

resource "azurerm_lb_rule" "consul" {
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8500
  frontend_ip_configuration_name = "consulserverNicconfiguration"
  probe_id                       = azurerm_lb_probe.consul.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.consul.id]
}


resource "azurerm_linux_virtual_machine" "consul-server-vm" {
  # IMPORTANT: IL-843 the Terraform resource name and the Azure
  # VM name must match for our track setup script to clean up
  # when Azure fails to make a VM
  name = "consul-server-vm"

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.consul.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }

  os_disk {
    # IMPORTANT: IL-843 the os disk name must be
    # "<tf resource name>-disk" for our Azure cleanup script to
    # work
    name                 = "consul-server-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  computer_name        = "consul-server-vm"
  admin_username       = "azure-user"
  custom_data          = base64encode(file("./scripts/consul-server.sh"))
 
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure-user"
    public_key = var.ssh_public_key
  }

  timeouts {
    create = "60m"
    read   = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "azurerm_network_interface_security_group_association" "consul" {
  network_interface_id      = azurerm_network_interface.consul.id
  network_security_group_id = azurerm_network_security_group.consul-sg.id
}
