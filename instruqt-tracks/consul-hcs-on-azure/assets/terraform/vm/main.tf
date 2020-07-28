provider "azurerm" {
  version = "=2.0.0"
  features {}
}

variable "remote_state" {
  default = "/root/terraform"
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "${var.remote_state}/vnet/terraform.tfstate"
  }
}

data "terraform_remote_state" "hcs" {
  backend = "local"

  config = {
    path = "${var.remote_state}/hcs/terraform.tfstate"
  }
}

resource "azurerm_network_interface" "vm" {
  name                = "vm-nic"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.frontend_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_user_assigned_identity" "vm" {
  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name

  name = "payments"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-vm"
  location              = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name   = data.terraform_remote_state.vnet.outputs.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm.id]
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vm-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm"
    admin_username = "azure-user"
    custom_data    = templatefile(
      "${path.module}/scripts/vm.sh",
      {
        ca = "${base64decode(data.terraform_remote_state.hcs.outputs.hcs_config.ca_file)}"
        consul_join_addr = "${jsondecode(base64decode(data.terraform_remote_state.hcs.outputs.hcs_config.consulConfigFile)).retry_join[0]}"
        consul_datacenter = "${jsondecode(base64decode(data.terraform_remote_state.hcs.outputs.hcs_config.consulConfigFile)).datacenter}"
        consul_gossip_key = "${jsondecode(base64decode(data.terraform_remote_state.hcs.outputs.hcs_config.consulConfigFile)).encrypt}"
      }
    )
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    environment = "staging"
  }
}