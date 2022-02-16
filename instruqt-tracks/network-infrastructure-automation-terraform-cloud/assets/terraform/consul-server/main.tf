terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.0.0"
    }
  }
}

provider "azurerm" {
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
  name                = "consulserverNIC"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  ip_configuration {
    name                          = "consulserverNicConfiguration"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[2]
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Instruqt"
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
}

resource "azurerm_lb_backend_address_pool" "consul" {
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "consul" {
  network_interface_id    = azurerm_network_interface.consul.id
  ip_configuration_name   = "consulserverNicConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.consul.id
}

resource "azurerm_lb_probe" "consul-ssh" {
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "consul-ssh"
  port                = 22
}

resource "azurerm_lb_rule" "consul-ssh" {
  resource_group_name            = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul-ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "consulserverNicconfiguration"
  probe_id                       = azurerm_lb_probe.consul.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.consul.id
}

resource "azurerm_lb_probe" "consul" {
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id     = azurerm_lb.consul.id
  name                = "consul-http"
  port                = 8500
}

resource "azurerm_lb_rule" "consul" {
  resource_group_name            = data.terraform_remote_state.vnet.outputs.resource_group_name
  loadbalancer_id                = azurerm_lb.consul.id
  name                           = "consul"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8500
  frontend_ip_configuration_name = "consulserverNicconfiguration"
  probe_id                       = azurerm_lb_probe.consul.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.consul.id
}


resource "azurerm_virtual_machine" "consul-server-vm" {
  name = "consul-server-vm"

  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.consul.id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "consulserverDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "consul-server-vm"
    admin_username = "azure-user"
    custom_data    = file("./scripts/consul-server.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }

  }

}

resource "azurerm_network_interface_security_group_association" "consul" {
  network_interface_id      = azurerm_network_interface.consul.id
  network_security_group_id = azurerm_network_security_group.consul-sg.id
}
