

resource "azurerm_resource_group" "consulnetworkautomation" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source = "./network"
  resource_group_name = var.resource_group_name
  location = var.location
  owner = var.owner
    depends_on = [
    azurerm_resource_group.consulnetworkautomation
  ]
}

module "pan-os" {
  source           = "./pan-os"
  resource_group_name = var.resource_group_name
  location = var.location
  owner = var.owner
  public_subnet  =  module.network.secure_network_subnets[0]
  private_subnet =  module.network.secure_network_subnets[1]
  securemgmt_subnet      = module.network.secure_network_subnets[2]
  depends_on = [
    azurerm_resource_group.consulnetworkautomation
  ]
}

module "sharedservices" {
  source           = "./sharedservices"
  resource_group_name = var.resource_group_name
  location = var.location
  owner = var.owner
  boundary_subnet     = module.network.shared_network_subnets[0]
  vault_subnet     = module.network.shared_network_subnets[1]
  consul_subnet = module.network.shared_network_subnets[2]
  depends_on = [
    azurerm_resource_group.consulnetworkautomation
  ]
}

module "loadbalancer" {
  source = "./loadbalancer"
  resource_group_name = var.resource_group_name
  location = var.location
  owner = var.owner
  web_subnet     = module.network.app_network_subnets[0]
  app_subnet     = module.network.app_network_subnets[1]
  db_subnet     = module.network.app_network_subnets[2]
  depends_on = [
    azurerm_resource_group.consulnetworkautomation
  ]
}

module "routing" {
  source = "./routing"
  resource_group_name = var.resource_group_name
  location = var.location
  owner = var.owner
  web_subnet     = module.network.app_network_subnets[0]
  app_subnet     = module.network.app_network_subnets[1]
  db_subnet     = module.network.app_network_subnets[2]
  boundary_subnet     = module.network.shared_network_subnets[0]
  vault_subnet     = module.network.shared_network_subnets[1]
  consul_subnet     = module.network.shared_network_subnets[2]
  depends_on = [
    azurerm_resource_group.consulnetworkautomation
  ]
}

# module "loggingservices" {
#   source = "./loggingservices"
#   resource_group_name = var.resource_group_name
#   location = var.location
#   owner = var.owner
#   boundary_subnet     = module.network.shared_network_subnets[0]
#   consul_server_ip     = module.sharedservices.consul_ip
#   depends_on = [
#     module.sharedservices
#   ]
# }

# module "webservice" {
#   source = "./webservice"
#   resource_group_name = var.resource_group_name
#   location = var.location
#   owner = var.owner
#   web_subnet     = module.network.app_network_subnets[0]
#   consul_server_ip       = module.sharedservices.consul_ip
#   web_count = var.web_count
#   depends_on = [
#     azurerm_resource_group.consulnetworkautomation
#   ]

# }

# module "dbservice" {
#   source = "./dbservice"
#   resource_group_name = var.resource_group_name
#   location = var.location
#   owner = var.owner
#   db_subnet     = module.network.app_network_subnets[1]
#   consul_server_ip       = module.sharedservices.consul_ip
#   depends_on = [
#     azurerm_resource_group.consulnetworkautomation
#   ]

# }



# module "dbout" {
#   source = "./dbout"
#   resource_group_name = var.resource_group_name
#   location = var.location
#   owner = var.owner
#   db_subnet     = module.network.app_network_subnets[0]
#   consul_server_ip       = module.sharedservices.consul_ip
#   depends_on = [
#     azurerm_resource_group.consulnetworkautomation
#   ]

# }


# module "app" {
#   source           = "./app"
#   resourcename     = module.network.resource_group_name
#   resourcelocation = module.network.resource_group_location
#   app_subnet       = module.network.app_subnet
#   untrusted_subnet = module.network.untrusted_subnet
#   consul_server_ip       = module.consul.consul_ip
#   privateipfwnic2        = module.pan-os.privateipfwnic2
#   privateipfwnic3        = module.pan-os.privateipfwnic3
# }

# # module "boundary" {
# #   source              = "./boundary"
# #   resourcename     = module.network.resource_group_name
# #   resourcelocation = module.network.resource_group_location
# #   controller_vm_count = 1
# #   worker_vm_count     = 1
# #   boundary_version    = "0.9.0"
# #   shared_subnet    = module.network.shared_svcs_subnets[0]
# #   mgmt_subnet      = module.network.mgmt_subnet
# #   my_ip = "76.68.107.212"
# # }