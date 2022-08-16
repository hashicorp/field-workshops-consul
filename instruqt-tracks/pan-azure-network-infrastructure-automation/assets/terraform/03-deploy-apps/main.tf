data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "../01-deploy-infra/terraform.tfstate"
  }
}

module "web-tier" {
  source = "./web-tier"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  owner = data.terraform_remote_state.environment.outputs.owner
  web_subnet     = data.terraform_remote_state.environment.outputs.app_network_web_subnet
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul_ip
  web-id = data.terraform_remote_state.environment.outputs.web-id
  app-lb = data.terraform_remote_state.environment.outputs.app-lb
  web_count = var.web_count
}

module "app-tier" {
  source = "./app-tier"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  owner = data.terraform_remote_state.environment.outputs.owner
  app_subnet     = data.terraform_remote_state.environment.outputs.app_network_app_subnet
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul_ip
  app-id = data.terraform_remote_state.environment.outputs.app-id
  app_count = var.app_count
}


module "database-tier" {
  source = "./database-tier"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  owner = data.terraform_remote_state.environment.outputs.owner
  db_subnet     = data.terraform_remote_state.environment.outputs.app_network_db_subnet
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul_ip
  db-id = data.terraform_remote_state.environment.outputs.db-id
  db_count = var.db_count
}
