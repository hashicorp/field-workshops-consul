provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "terraform_remote_state" "vnet" {
  backend = "local"
  config = {
    path = "../vnet/terraform.tfstate"
  }
}

# Create network interface
resource "azurerm_network_interface" "consulserver-nic" {
    name                      = "consulserverNIC"
    location                  = "eastus"
    resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name

    ip_configuration {
        name                          = "consulserverNicConfiguration"
        subnet_id                     = data.terraform_remote_state.vnet.outputs.shared_svcs_subnets[2]
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "Instruqt"
    }
}

resource "azurerm_virtual_machine" "consul-server-vm" {
  name = "consul-server-vm"

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.consulserver-nic.id]
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
    computer_name = "consul-server-vm"
    admin_username       = "azure-user"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }

  }

}
