resource "azurerm_public_ip" "consul" {
  name                = "consul-server-ip"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "mgw" {
  name                = "consul-mgw-ip"
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "consul" {
  name                = "consul-server-nic"
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  ip_configuration {
    name                          = "config"
    subnet_id                     = data.terraform_remote_state.infra.outputs.azure_shared_svcs_public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.consul.id
  }

  tags = {
    Name = "consul"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}

resource "azurerm_virtual_machine" "consul" {
  name                  = "consul-server-vm"
  location              = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name   = data.terraform_remote_state.infra.outputs.azure_rg_name
  network_interface_ids = [azurerm_network_interface.consul.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "consul-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "consul-server-0"
    admin_username = "ubuntu"
    custom_data    = data.template_file.azure-server-init.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    Name = "consul"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}

resource "tls_private_key" "azure_consul_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "azure_consul_server" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.azure_consul_server.private_key_pem

  subject {
    common_name = "consul-server-0.server.azure-west-us-2.consul"
  }

  dns_names    = ["consul-server-0.server.azure-west-us-2.consul", "server.azure-west-us-2.consul", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "azure_consul_server" {
  cert_request_pem   = tls_cert_request.azure_consul_server.cert_request_pem
  ca_key_algorithm   = tls_private_key.shared_ca.algorithm
  ca_private_key_pem = tls_private_key.shared_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.shared_ca.cert_pem

  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth"
  ]
}

data "template_file" "azure-server-init" {
  template = file("${path.module}/scripts/azure_consul_server.sh")
  vars = {
    ca_cert             = tls_self_signed_cert.shared_ca.cert_pem
    cert                = tls_locally_signed_cert.azure_consul_server.cert_pem,
    key                 = tls_private_key.azure_consul_server.private_key_pem,
    primary_wan_gateway = "${aws_instance.mesh_gateway.public_ip}:443"
  }
}

resource "azurerm_network_interface" "consul-mgw" {
  name                = "consul-mgw-nic"
  location            = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name = data.terraform_remote_state.infra.outputs.azure_rg_name

  ip_configuration {
    name                          = "config"
    subnet_id                     = data.terraform_remote_state.infra.outputs.azure_shared_svcs_public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgw.id
  }

  tags = {
    Name = "consul"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}

data "template_file" "azure-mgw-init" {
  template = file("${path.module}/scripts/azure_mesh_gateway.sh")
  vars = {
    env             = data.terraform_remote_state.infra.outputs.env
    ca_cert         = tls_self_signed_cert.shared_ca.cert_pem
    subscription_id = data.azurerm_subscription.primary.subscription_id
  }
}

resource "azurerm_role_assignment" "mgw" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azurerm_virtual_machine.consul-mgw.identity.0.principal_id
}

resource "azurerm_virtual_machine" "consul-mgw" {
  name                  = "consul-mgw-vm"
  location              = data.terraform_remote_state.infra.outputs.azure_rg_location
  resource_group_name   = data.terraform_remote_state.infra.outputs.azure_rg_name
  network_interface_ids = [azurerm_network_interface.consul-mgw.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "consul-mgw-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "consul-mgw"
    admin_username = "ubuntu"
    custom_data    = data.template_file.azure-mgw-init.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    Name = "consul-mgw"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }

}
