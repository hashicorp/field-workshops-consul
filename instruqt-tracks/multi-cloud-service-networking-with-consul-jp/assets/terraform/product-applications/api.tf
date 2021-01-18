data "azurerm_image" "ubuntu" {
  name_regex          = "hashistack-*"
  resource_group_name = "packer"
}

resource "azurerm_public_ip" "vm" {
  name                = "product-api-ip"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm" {
  name                = "product-api-nic"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.terraform_remote_state.infra.outputs.azure_app_public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "product-api-vm"
  resource_group_name   = data.terraform_remote_state.infra.outputs.azure_rg_name
  location              = data.terraform_remote_state.infra.outputs.azure_rg_location
  network_interface_ids = [azurerm_network_interface.vm.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type         = "UserAssigned"
    identity_ids = [data.terraform_remote_state.iam.outputs.azure_product_api_user_assigned_identity_id]
  }

  storage_image_reference {
    id = data.azurerm_image.ubuntu.id
  }
  storage_os_disk {
    name              = "product-api-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "product-api"
    admin_username = "ubuntu"
    custom_data    = data.template_file.product-api-init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    environment = "staging"
  }
}

data "template_file" "product-api-init" {
  template = file("${path.module}/scripts/api.sh")
  vars = {
    env               = data.terraform_remote_state.infra.outputs.env
    subscription_id   = data.azurerm_subscription.primary.subscription_id
    postgres_password = data.terraform_remote_state.db.outputs.postgres_password
  }
}
