resource "azurerm_key_vault" "vault" {
  name                        = "vault-${data.terraform_remote_state.infra.outputs.env}"
  resource_group_name         = data.terraform_remote_state.infra.outputs.azure_rg_name
  location                    = data.terraform_remote_state.infra.outputs.azure_rg_location
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
      "wrapKey",
      "unwrapKey",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_key" "vault" {
  name         = "vault-key-${data.terraform_remote_state.infra.outputs.env}"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_network_interface" "vault" {
  name                = "vault-server-nic"
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  ip_configuration {
    name                          = "config"
    subnet_id                     = data.terraform_remote_state.infra.outputs.azure_shared_svcs_public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vault.id
  }

  tags = {
    Name = "vault"
    Env  = "vault-${data.terraform_remote_state.infra.outputs.env}"
  }

}

data "template_file" "azure-vault-init" {
  template = file("${path.module}/scripts/azure_vault.sh")
  vars = {
    tenant_id  = data.azurerm_client_config.current.tenant_id
    vault_name = azurerm_key_vault.vault.name
    key_name   = azurerm_key_vault_key.vault.name
  }
}

resource "azurerm_virtual_machine" "vault" {
  name                  = "vault-server-vm"
  location              = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name   = data.terraform_remote_state.infra.outputs.azure_rg_name
  network_interface_ids = [azurerm_network_interface.vault.id]
  vm_size               = "Standard_DS1_v2"

  identity {
    type = "SystemAssigned"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vault-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vault-server-0"
    admin_username = "ubuntu"
    custom_data    = data.template_file.azure-vault-init.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    Name = "vault"
    Env  = "vault-${data.terraform_remote_state.infra.outputs.env}"
  }

}

resource "azurerm_role_assignment" "vault" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Crypto User (preview)"
  principal_id         = azurerm_virtual_machine.vault.identity.0.principal_id
}

resource "azurerm_public_ip" "vault" {
  name                = "vault-server-ip"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  allocation_method   = "Static"
}
