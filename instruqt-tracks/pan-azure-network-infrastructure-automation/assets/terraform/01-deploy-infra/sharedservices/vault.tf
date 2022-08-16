
resource "random_string" "vaultparticipant" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}
resource "azurerm_public_ip" "vault" {
  name                = "vault-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vault" {
  name                = "vault-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "vaultconfiguration"
    subnet_id                     = var.vault_subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "vault" {
  name                = "vault-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "vaultconfiguration"
    public_ip_address_id = azurerm_public_ip.vault.id
  }
}

resource "azurerm_lb_backend_address_pool" "vault" {
  loadbalancer_id = azurerm_lb.vault.id
  name            = "vaultBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "vault" {
  network_interface_id    = azurerm_network_interface.vault.id
  ip_configuration_name   = "vaultconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vault.id
}

resource "azurerm_lb_probe" "vault" {
  loadbalancer_id = azurerm_lb.vault.id
  name            = "vault-http"
  port            = 8200
}

resource "azurerm_lb_rule" "vault" {
  loadbalancer_id                = azurerm_lb.vault.id
  name                           = "vault"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8200
  frontend_ip_configuration_name = "vaultconfiguration"
  probe_id                       = azurerm_lb_probe.vault.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vault.id]
}


resource "azurerm_linux_virtual_machine" "vault" {
  name                  = "vault-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vault.id]
  size                  = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "vaultmyOsDisk${random_string.vaultparticipant.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data = base64encode(file("${path.module}/scripts/vault.sh"))

  computer_name                   = "vault-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.vault.public_key_openssh
  }

  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_security_group" "vault" {
  name                = "vault-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-vault-http-all"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "vault" {
  network_interface_id      = azurerm_network_interface.vault.id
  network_security_group_id = azurerm_network_security_group.vault.id
    depends_on = [
    azurerm_linux_virtual_machine.vault
  ]
}


## SSH Key 

resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "vault" {
  name                = "vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = tls_private_key.vault.public_key_openssh
}

resource "null_resource" "vaultkey" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.vault.private_key_pem}\" > ${azurerm_ssh_public_key.vault.name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }

}

