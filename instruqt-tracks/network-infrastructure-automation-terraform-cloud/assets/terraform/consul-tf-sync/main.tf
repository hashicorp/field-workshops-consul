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

# Create network interface
resource "azurerm_network_interface" "cts-nic" {
  name                = "ctsNIC"
  location            = "eastus"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  ip_configuration {
    name                          = "ctsNicConfiguration"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.mgmt_subnet
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Instruqt"
  }
}

resource "azurerm_virtual_machine" "consul-terraform-sync" {
  name = "consul-terraform-sync"

  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.cts-nic.id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "ctsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "consul-terraform-sync"
    admin_username = "azure-user"
    custom_data    = base64encode(templatefile("./scripts/consul-tf-sync.sh", { vault_token = var.vault_token, vault_addr = var.vault_addr, consul_server_ip = var.consul_server_ip, bigip_mgmt_addr = var.bigip_mgmt_addr, bigip_admin_user = var.bigip_admin_user, panos_mgmt_addr = var.panos_mgmt_addr, panos_username = var.panos_username }))
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }

  }

}

resource "azurerm_network_interface_security_group_association" "cts" {
  network_interface_id      = azurerm_network_interface.cts-nic.id
  network_security_group_id = azurerm_network_security_group.cts-sg.id
}
