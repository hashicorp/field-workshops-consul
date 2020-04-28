resource "azurerm_resource_group" "consul" {
  name     = "${random_id.environment_name.hex}-consul-cluster"
  location = var.region
}

resource "azurerm_user_assigned_identity" "consul_server_iam" {
  name                = "${random_id.environment_name.hex}-consul"
  resource_group_name = azurerm_resource_group.consul.name
  location            = var.region
}

resource "azurerm_role_assignment" "consul_reader" {
  scope                = azurerm_resource_group.consul.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.consul_server_iam.principal_id
}

data "template_file" "install_hashitools_consul" {
  template = file("${path.module}/scripts/install_hashitools_consul.sh.tpl")

  vars = {
    image_id               = data.azurerm_image.hashitools.id
    resource_group         = azurerm_resource_group.consul.name
    vmss_name              = local.vmss_name
    subscription_id        = data.azurerm_client_config.current.subscription_id
    environment_name       = random_id.environment_name.hex
    datacenter             = replace(var.region, " ", "-")
    bootstrap_expect       = var.redundancy_zones ? length(var.availability_zones) : var.consul_nodes
    total_nodes            = var.consul_nodes
    gossip_key             = random_id.consul_gossip_encryption_key.b64_std
    master_token           = random_uuid.consul_master_token.result
    agent_server_token     = random_uuid.consul_agent_server_token.result
    snapshot_token         = random_uuid.consul_snapshot_token.result
    consul_cluster_version = var.consul_cluster_version
    redundancy_zones       = var.redundancy_zones
    bootstrap              = var.bootstrap
    enable_connect         = var.enable_connect
  }
}

///////////////////
// Compute
///////////////////

resource "azurerm_virtual_machine_scale_set" "consul_cluster" {
  name                = local.vmss_name
  location            = var.region
  resource_group_name = azurerm_resource_group.consul.name

  upgrade_policy_mode  = "Manual"
  automatic_os_upgrade = false

  overprovision = false
  zones         = var.availability_zones

  sku {
    capacity = var.consul_nodes
    tier     = "Standard"
    name     = var.consul_vm_size
  }

  storage_profile_image_reference {
    id = data.azurerm_image.hashitools.id
  }

  storage_profile_os_disk {
    managed_disk_type = var.vm_managed_disk_type
    create_option     = "FromImage"
    caching           = "ReadWrite"
    os_type           = "linux"
  }

  network_profile {
    name    = "${random_id.environment_name.hex}-consul-net"
    primary = true
    ip_configuration {
      name                           = "${random_id.environment_name.hex}-consul-net-ip"
      primary                        = true
      subnet_id                      = var.subnet_id
      application_security_group_ids = [azurerm_application_security_group.consul_servers.id]
    }
  }

  os_profile {
    computer_name_prefix = "${random_id.environment_name.hex}-consul"
    admin_username       = var.instance_username
    custom_data          = var.use_cloud_init ? local.consul_init_script : ""
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.instance_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.consul_server_iam.id]
  }

  dynamic "extension" {
    for_each = var.use_cloud_init ? [] : local.consul_init_script.*

    content {
      name                       = "${random_id.environment_name.hex}-consul-init"
      publisher                  = "Microsoft.Azure.Extensions"
      type                       = "CustomScript"
      type_handler_version       = "2.0"
      auto_upgrade_minor_version = false

      settings = <<-EOT
      {
        "skipDos2Unix": true,
        "script": "${local.consul_init_script}"
      }
      EOT
    }
  }

  extension {
    name                       = "${random_id.environment_name.hex}-consul-health"
    publisher                  = "Microsoft.ManagedServices"
    type                       = "ApplicationHealthLinux"
    type_handler_version       = "1.0"
    auto_upgrade_minor_version = false

    settings = <<-EOT
    {
      "protocol": "http",
      "port": 8500,
      "requestPath": "v1/agent/metrics"
    }
    EOT

    // Don't report application health to VMSS until the provisioning script has exited successfully.
    provision_after_extensions = var.use_cloud_init ? [] : ["${random_id.environment_name.hex}-consul-init"]
  }

  // TODO: Proximity placement group config

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.cluster_data.primary_blob_endpoint
  }

  tags = {
    Cluster-Version = var.consul_cluster_version
    Owner           = var.owner
    TTL             = var.ttl
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [azurerm_role_assignment.consul_reader]
}

locals {
  // Avoid dep cycle between the VMSS and script template while staying DRY
  vmss_name          = "${random_id.environment_name.hex}-consul-servers"
  consul_init_script = base64gzip(data.template_file.install_hashitools_consul.rendered)
}

///////////////////
// Network
///////////////////

resource "azurerm_application_security_group" "consul_servers" {
  location            = var.region
  name                = "${random_id.environment_name.hex}-consul-servers"
  resource_group_name = azurerm_resource_group.consul.name
}
