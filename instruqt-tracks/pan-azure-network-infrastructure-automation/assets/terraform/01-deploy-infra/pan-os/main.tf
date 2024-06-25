
resource "random_id" "suffix" {
  byte_length = 2
}

resource "random_integer" "password-length" {
  min = 12
  max = 25
}

resource "random_password" "pafwpassword" {
  length           = random_integer.password-length.result
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "_%!"
}

resource "azurerm_storage_account" "pan_fw_stg_ac" {
  name                     = "strgaccpafw${random_id.suffix.dec}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_public_ip" "PublicIP_0" {
  name                = "fwMgmtPublicIP-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.FirewallDnsName}-${random_id.suffix.dec}"
}

resource "azurerm_public_ip" "PublicIP_1" {
  name                = "webPublicIP-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.WebServerDnsName}-${random_id.suffix.dec}"
}

resource "azurerm_network_interface" "VNIC0" {
  name                = "FWeth0-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_public_ip.PublicIP_0]

  ip_configuration {
    name                          = "ipconfig0"
    subnet_id                     = var.securemgmt_subnet
    private_ip_address_allocation = "Static"
    private_ip_address            = var.IPAddressMgmtNetwork
    public_ip_address_id          = azurerm_public_ip.PublicIP_0.id
  }

  tags = {
    displayName = "MgmtInterface"
  }
}

resource "azurerm_network_interface" "VNIC1" {
  name                = "FWeth1-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on           = [var.public_subnet]
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.public_subnet
    private_ip_address_allocation = "Static"
    private_ip_address            = var.IPAddressPublicNetwork
    public_ip_address_id          = azurerm_public_ip.PublicIP_1.id
  }

  tags = {
    displayName = "NetworkInterfaces1"
  }
}

resource "azurerm_network_interface" "VNIC2" {
  name                = "FWeth2-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on           = [var.private_subnet]
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = var.private_subnet
    private_ip_address_allocation = "Static"
    private_ip_address            = var.IPAddressPrivatedNetwork
  }

  tags = {
    displayName = "NetworkInterfaces2"
  }
}



resource "azurerm_virtual_machine" "PAN_FW_FW" {
  name                = "vmPanOS-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group_name
  vm_size             = "Standard_D3_v2"

  depends_on = [azurerm_network_interface.VNIC0,
    azurerm_network_interface.VNIC1,
    azurerm_network_interface.VNIC2,
    azurerm_public_ip.PublicIP_0,
    azurerm_public_ip.PublicIP_1
  ]
  plan {
    name      = var.fwSku
    publisher = var.fwPublisher
    product   = var.fwOffer
  }

  storage_image_reference {
    publisher = var.fwPublisher
    offer     = var.fwOffer
    sku       = var.fwSku
    version   = "latest"
  }

  storage_os_disk {
    name          = "vmPANW-${random_id.suffix.dec}-osDisk"
    vhd_uri       = "${azurerm_storage_account.pan_fw_stg_ac.primary_blob_endpoint}vhds/vmPANW-${random_id.suffix.dec}-${var.fwOffer}-${var.fwSku}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "vmPANW-${random_id.suffix.dec}"
    admin_username = var.adminUsername
    admin_password = random_password.pafwpassword.result
  }

  primary_network_interface_id = azurerm_network_interface.VNIC0.id
  network_interface_ids = [azurerm_network_interface.VNIC0.id,
    azurerm_network_interface.VNIC1.id,
    azurerm_network_interface.VNIC2.id
  ]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
