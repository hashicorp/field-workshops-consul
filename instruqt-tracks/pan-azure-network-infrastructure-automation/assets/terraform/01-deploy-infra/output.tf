output "bastion-ip" {
  value = "ssh -i bastion.pem azureuser@${module.sharedservices.bastion_ip}"
}

output "logging-ip" {
  value = "ssh -i logging.pem azureuser@${module.sharedservices.logging_ip}"
}
output "vault_lb" {
  value = "http://${module.sharedservices.vault_lb}"
}
output "vault_lb2" {
  value = module.sharedservices.vault_lb
}

output "vault_ip" {
  value = module.sharedservices.vault_ip
}

output "pa_username" {
  value = module.pan-os.pa_username
}
output "pa_password" {
  value     = module.pan-os.pa_password
  sensitive = true
}
output "https_paloalto_mgmt_ip" {
  value = "https://${module.pan-os.FirewallIP}"
}
output "paloalto_mgmt_ip" {
  value = module.pan-os.FirewallIP
}

output "web-lb" {
  value = module.loadbalancer.web-lb
}

output "app-lb" {
  value = module.loadbalancer.app-lb
}

output "db-lb" {
  value = module.loadbalancer.db-lb
}
output "WebFQDN" {
  value = "http://${module.pan-os.WebFQDN}"
  
}
output "privateipfwnic1" {
  value = module.pan-os.privateipfwnic1
}
output "privateipfwnic2" {
  value = module.pan-os.privateipfwnic2
}

output "azurerm_resource_group" {
 value = var.resource_group_name
}
output "location" {
 value = var.location
}
output "owner" {
 value = var.owner
}
output "consul_ip" {
  value = module.sharedservices.consul_ip
}
output "consul_lb" {
  value = "http://${module.sharedservices.consul_lb}"
}
output "app_network_web_subnet" {
  value = module.network.app_network_web_subnet
}
output "app_network_app_subnet" {
  value = module.network.app_network_app_subnet
}
output "app_network_db_subnet" {
  value = module.network.app_network_db_subnet
}
output "shared_network_consul_subnets" {
  value = module.network.shared_network_consul_subnets
}
  
output "web-id" {
  value = module.loadbalancer.web-id
}
output "app-id" {
  value = module.loadbalancer.app-id
}
output "db-id" {
  value = module.loadbalancer.db-id
}