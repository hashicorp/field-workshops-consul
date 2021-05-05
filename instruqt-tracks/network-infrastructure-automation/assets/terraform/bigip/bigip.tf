resource random_integer "password-length" {
  min = 12
  max = 25
}

resource "random_password" "bigippassword" {
  length           = random_integer.password-length.result
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "_%!"
}

data "template_file" "vm_onboard" {
  template = "${file("${path.module}/templates/bigip.tpl")}"

  vars = {
    uname = var.admin_username
    # replace this with a reference to the secret id
    upassword      = random_password.bigippassword.result
    DO_URL         = var.DO_URL
    AS3_URL        = var.AS3_URL
    TS_URL         = var.TS_URL
    libs_dir       = var.libs_dir
    onboard_log    = var.onboard_log
    ASM_POLICY_URL = var.ASM_POLICY_URL
  }
}

resource "azurerm_marketplace_agreement" "f5" {
  publisher = "f5-networks"
  offer     = "f5-big-ip-good"
  plan      = "f5-bigip-virtual-edition-25m-good-hourly"
}

# Create F5 BIGIP VMs
resource "azurerm_linux_virtual_machine" "f5bigip" {
  name = "bigip"
  depends_on = [azurerm_marketplace_agreement.f5]

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  network_interface_ids = [azurerm_network_interface.dmz-nic.id]
  size                  = var.instance_type
  //   zone                            = element(local.azs,count.index % length(local.azs))
  admin_username                  = var.admin_username
  admin_password                  = random_password.bigippassword.result
  disable_password_authentication = false


  # leave commented out until 15.1 is in the marketplace
  source_image_reference {
    publisher = var.publisher
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }
  # leave commented out until 15.1 is in the marketplace
  plan {
    name      = var.image_name
    publisher = var.publisher
    product   = var.product
  }
  # this is needed to reference the shared image
  # remove when 15.1 is in the marketplace
  #source_image_id = var.image_id

  os_disk {
    name                 = "bigip-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "100"
  }

  custom_data = base64encode(data.template_file.vm_onboard.rendered)

  tags = {
    Name        = "bigip"
    environment = "instruqt"
    workload    = "ltm"
  }
}

resource "azurerm_public_ip" "sip_public_ip" {
  name                = "bigip-public-ip"
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  allocation_method   = "Static"   # Static is required due to the use of the Standard sku
  sku                 = "Standard" # the Standard sku is required due to the use of availability zones
  // zones               =  [element(local.azs, count.index)]
  domain_name_label = data.terraform_remote_state.vnet.outputs.resource_group_name
  tags = {
    environment = "instruqt"
  }
}

resource "azurerm_network_interface" "dmz-nic" {
  name                 = "bigip-dmz-nic"
  location             = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name  = data.terraform_remote_state.vnet.outputs.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.dmz_subnet
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.sip_public_ip.id
  }

  tags = {
    environment = "instruqt"
  }
}

resource "azurerm_network_interface_security_group_association" "dmz-nic-security" {
  network_interface_id      = azurerm_network_interface.dmz-nic.id
  network_security_group_id = azurerm_network_security_group.f5_public.id
}
