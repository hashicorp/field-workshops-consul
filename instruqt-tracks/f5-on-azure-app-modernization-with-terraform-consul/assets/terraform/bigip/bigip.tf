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
  override_special = "_%@"
}

data "template_file" "vm_onboard" {
  template = "${file("${path.module}/templates/bigip.tpl")}"

  vars = {
    uname = var.admin_username
    # replace this with a reference to the secret id
    upassword   = random_password.bigippassword.result
    DO_URL      = var.DO_URL
    AS3_URL     = var.AS3_URL
    TS_URL      = var.TS_URL
    libs_dir    = var.libs_dir
    onboard_log = var.onboard_log
    ASM_POLICY_URL = var.ASM_POLICY_URL
  }
}

# Run Startup Script
resource "azurerm_virtual_machine_extension" "run_startup_cmd" {
  name                 = "bigip-startup"
  virtual_machine_id   = azurerm_linux_virtual_machine.f5bigip.id
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
        {
            "commandToExecute": "bash /var/lib/waagent/CustomData"
        }
    SETTINGS
}


# Create F5 BIGIP VMs
resource "azurerm_linux_virtual_machine" "f5bigip" {
  name                  = "bigip"

  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  network_interface_ids = [azurerm_network_interface.ext-nic.id]
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
    disk_size_gb         = "80"
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
  domain_name_label   = data.terraform_remote_state.vnet.outputs.resource_group_name
  tags = {
    environment = "instruqt"
  }
}

resource "azurerm_network_interface" "ext-nic" {
  name                 = "bigip-external-nic"
  location             = data.terraform_remote_state.vnet.outputs.resource_group_location
  resource_group_name  = data.terraform_remote_state.vnet.outputs.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.legacy_subnets[0]
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.sip_public_ip.id
  }


  tags = {
    environment = "instruqt"

  }
}
resource "azurerm_network_interface_security_group_association" "ext-nic-security" {
  network_interface_id      = azurerm_network_interface.ext-nic.id
  network_security_group_id = azurerm_network_security_group.f5_public.id
}



# Run Startup Script
// resource "azurerm_virtual_machine_extension" "run_startup_cmd" {
//   count                = local.ltm_instance_count
//   name                 = format("%s-bigip-startup-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//   virtual_machine_id   = azurerm_linux_virtual_machine.f5bigip[count.index].id
//   publisher            = "Microsoft.OSTCExtensions"
//   type                 = "CustomScriptForLinux"
//   type_handler_version = "1.2"

//   settings = <<SETTINGS
//         {
//             "commandToExecute": "bash /var/lib/waagent/CustomData"
//         }
//     SETTINGS

//   tags = {
//     Name        = format("%s-bigip-startup-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }


// # Create Network Security Group and rule
// # https://support.f5.com/csp/article/K13946
// # https://support.f5.com/csp/article/K9057
// resource "azurerm_network_security_group" "management_sg" {
//   name                = format("%s-mgmt_sg-%s", var.prefix, random_id.randomId.hex)
//   location            = data.terraform_remote_state.vnet.outputs.resource_group_location
//   resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

//   security_rule {
//     name                       = "SSH"
//     priority                   = 1001
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Tcp"
//     source_port_range          = "*"
//     destination_port_range     = "22"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   security_rule {
//     name                       = "HTTP"
//     priority                   = 1000
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Tcp"
//     source_port_range          = "*"
//     destination_port_range     = "8080"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   security_rule {
//     name                       = "HTTPS"
//     priority                   = 1002
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Tcp"
//     source_port_range          = "*"
//     destination_port_range     = "443"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   security_rule {
//     name                       = "configsync"
//     priority                   = 1003
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Udp"
//     source_port_range          = "*"
//     destination_port_range     = "1026"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   security_rule {
//     name                       = "configsync-cmi"
//     priority                   = 1004
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Tcp"
//     source_port_range          = "*"
//     destination_port_range     = "4353"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   tags = {
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }

// # Create interfaces for the BIGIPs
// resource "azurerm_network_interface" "mgmt-nic" {
//   count                     = local.ltm_instance_count
//   name                      = format("%s-mgmtnic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//   location                  = data.terraform_remote_state.vnet.outputs.resource_group_location
//   resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name

//   ip_configuration {
//     name                          = "primary"
//     subnet_id                     = azurerm_subnet.management[count.index % length(local.azs)].id
//     private_ip_address_allocation = "Dynamic"
//     public_ip_address_id          = azurerm_public_ip.management_public_ip[count.index].id
//   }

//   tags = {
//     Name        = format("%s-mgmtnic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }
// resource "azurerm_network_interface_security_group_association" "mgmt-nic-security" {
//   count                     = local.ltm_instance_count
//   network_interface_id      = azurerm_network_interface.mgmt-nic[count.index].id
//   network_security_group_id = azurerm_network_security_group.management_sg.id
// }

// # Create Application Traffic Network Security Group and rule

//   security_rule {
//     name                       = "configsync"
//     priority                   = 1003
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Udp"
//     source_port_range          = "*"
//     destination_port_range     = "1026"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   security_rule {
//     name                       = "configsync-cmi"
//     priority                   = 1004
//     direction                  = "Inbound"
//     access                     = "Allow"
//     protocol                   = "Tcp"
//     source_port_range          = "*"
//     destination_port_range     = "4353"
//     source_address_prefix      = "*"
//     destination_address_prefix = "*"
//   }

//   tags = {
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }

// resource "azurerm_network_interface" "int-nic" {
//   count                     = local.ltm_instance_count
//   name                      = format("%s-intnic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//   location                  = data.terraform_remote_state.vnet.outputs.resource_group_location
//   resource_group_name       = data.terraform_remote_state.vnet.outputs.resource_group_name
//   enable_ip_forwarding      = true

//   ip_configuration {
//     name                          = "primary"
//     subnet_id                     = azurerm_subnet.private[count.index % length(local.azs)].id
//     private_ip_address_allocation = "Dynamic"
//     primary                       = true
//   }

//   tags = {
//     Name        = format("%s-intnic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }
// resource "azurerm_network_interface_security_group_association" "int-nic-security" {
//   count                     = local.ltm_instance_count
//   network_interface_id      = azurerm_network_interface.int-nic[count.index].id
//   network_security_group_id = azurerm_network_security_group.management_sg.id
// }

// # Create public IPs for BIG-IP management UI
// resource "azurerm_public_ip" "management_public_ip" {
//   count               = local.ltm_instance_count
//   name                = format("%s-bigip-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//   location            = data.terraform_remote_state.vnet.outputs.resource_group_location
//   resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
//   allocation_method   = "Static"   # Static is required due to the use of the Standard sku
//   sku                 = "Standard" # the Standard sku is required due to the use of availability zones
//   zones               = [element(local.azs, count.index)]

//   tags = {
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }


// # Create public IPs for JuiceShop
// resource "azurerm_public_ip" "juiceshop_public_ip" {
//   count               = local.ltm_instance_count
//   name                = format("%s-juiceshop-%s-%s", var.prefix, count.index, random_id.randomId.hex)
//   location            = data.terraform_remote_state.vnet.outputs.resource_group_location
//   resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
//   allocation_method   = "Static"   # Static is required due to the use of the Standard sku
//   sku                 = "Standard" # the Standard sku is required due to the use of availability zones
//   zones               = [element(local.azs, count.index)]

//   tags = {
//     environment = var.specification[var.specification_name]["environment"]
//   }
// }

// # Setup Onboarding scripts
// data "template_file" "vm_onboard" {
//   template = "${file("${path.module}/onboard.tpl")}"

//   vars = {
//     uname = var.admin_username
//     # replace this with a reference to the secret id
//     upassword   = random_password.bigippassword.result
//     DO_URL      = var.DO_URL
//     AS3_URL     = var.AS3_URL
//     TS_URL      = var.TS_URL
//     libs_dir    = var.libs_dir
//     onboard_log = var.onboard_log
//   }
// }


// resource "null_resource" "clusterDO" {
//   count = local.ltm_instance_count
//   # cluster member node
//   provisioner "local-exec" {
//     command = <<-EOT
//         sleep 60

//         curl -s -k -X POST https://${azurerm_public_ip.management_public_ip[count.index].ip_address}:443/mgmt/shared/declarative-onboarding \
//               -H 'Content-Type: application/json' \
//               --max-time 600 \
//               --retry 10 \
//               --retry-delay 30 \
//               --retry-max-time 600 \
//               --retry-connrefused \
//               -u "${var.admin_username}:${random_password.bigippassword.result}" \
//               -d '${data.template_file.clustermemberDO[count.index].rendered}'
//         EOT
//   }
//   depends_on = [
//     azurerm_linux_virtual_machine.f5bigip,
//     azurerm_virtual_machine_extension.run_startup_cmd
//   ]
// }



// data "template_file" "clustermemberDO" {
//   count = local.ltm_instance_count
//   template = file("${path.module}/onboard_do.json")
//   vars = {
//     bigip_hostname              = azurerm_network_interface.mgmt-nic[count.index].private_ip_address
//     bigip_license               = ""
//     bigiq_license_host          = ""
//     bigiq_license_username      = ""
//     bigiq_license_password      = ""
//     bigiq_license_licensepool   = ""
//     bigiq_license_skuKeyword1   = ""
//     bigiq_license_skuKeyword2   = ""
//     bigiq_license_unitOfMeasure = ""
//     bigiq_hypervisor            = ""
//     name_servers                = join(",", formatlist("\"%s\"", ["168.63.129.16"])) # formatlist() is used to prepare lists of quoted strings for a json declaration
//     search_domain               = "f5.com"
//     ntp_servers                 = join(",", formatlist("\"%s\"", ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org"]))
//     internal_self_ip            = azurerm_network_interface.int-nic[count.index].private_ip_address
//     external_self_ip            = azurerm_network_interface.ext-nic[count.index].private_ip_address
//     failovergroup_members       = join(",", formatlist("\"%s\"", azurerm_network_interface.mgmt-nic[*].private_ip_address))
//     local_password              = random_password.bigippassword.result
//     remote_password             = random_password.bigippassword.result
//     remote_id                   = count.index > 0 ? 0 : 1
//     default_gateway_ip          = cidrhost(cidrsubnet(var.specification[var.specification_name]["cidr"], 8, 20 + (count.index % length(local.azs))), 1)
//   }
// }
