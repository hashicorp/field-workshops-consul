terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.25.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "../01-deploy-infra/terraform.tfstate"
  }
}

# Deploy Consul Terraform Sync

resource "random_string" "ctsparticipant" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_public_ip" "cts" {
  name                = "cts-ip"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "ctsnic" {
  name                = "ctsnic"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location

  ip_configuration {
    name                          = "consulctsconfiguration"
    subnet_id                     = data.terraform_remote_state.environment.outputs.shared_network_consul_subnets
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_lb" "cts" {
  name                = "cts-lb"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "consulctsconfiguration"
    public_ip_address_id = azurerm_public_ip.cts.id
  }
}


resource "azurerm_lb_backend_address_pool" "cts" {
  loadbalancer_id = azurerm_lb.cts.id
  name            = "ctsBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "cts" {
  network_interface_id    = azurerm_network_interface.ctsnic.id
  ip_configuration_name   = "consulctsconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.cts.id
}

resource "azurerm_lb_probe" "cts" {
  loadbalancer_id = azurerm_lb.cts.id
  name            = "cts-http"
  port            = 22
}

resource "azurerm_lb_rule" "cts" {
  loadbalancer_id                = azurerm_lb.cts.id
  name                           = "cts"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "consulctsconfiguration"
  probe_id                       = azurerm_lb_probe.cts.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.cts.id]
}



resource "azurerm_linux_virtual_machine" "consul-terraform-sync" {
  name                  = "consul-terraform-sync"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  network_interface_ids = [azurerm_network_interface.ctsnic.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "ctsmyOsDisk${random_string.ctsparticipant.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data          = base64encode(templatefile("./scripts/consul-tf-sync.sh", { 
    vault_token = "root", 
    vault_addr = data.terraform_remote_state.environment.outputs.vault_lb2, 
    CONSUL_VERSION = "1.12.2",
    CTS_CONSUL_VERSION = "0.6.0",
    CONSUL_URL = "https://releases.hashicorp.com/consul-terraform-sync",
    consul_server_ip = data.terraform_remote_state.environment.outputs.consul_ip,
    panos_mgmt_addr = data.terraform_remote_state.environment.outputs.paloalto_mgmt_ip,
    panos_username = data.terraform_remote_state.environment.outputs.pa_username,
    local_ipv4 = azurerm_network_interface.ctsnic.ip_configuration.0.private_ip_address
  }))
  computer_name                   = "cts-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.cts.public_key_openssh
  }

  tags = {
    environment = "staging"
  }
}



resource "azurerm_network_interface_security_group_association" "cts" {
  network_interface_id      = azurerm_network_interface.ctsnic.id
  network_security_group_id = azurerm_network_security_group.cts-sg.id
    depends_on = [
    azurerm_linux_virtual_machine.consul-terraform-sync
  ]
}


## SSH Key 

resource "tls_private_key" "cts" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "cts" {
  name                = "cts"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  public_key          = tls_private_key.cts.public_key_openssh
}

resource "null_resource" "cts" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.cts.private_key_pem}\" > ${azurerm_ssh_public_key.cts.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}





