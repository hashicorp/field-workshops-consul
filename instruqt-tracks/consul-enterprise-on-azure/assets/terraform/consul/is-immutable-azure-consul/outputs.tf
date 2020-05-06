output "consul_rg" {
  value = azurerm_resource_group.consul.name
}

output "consul_asg" {
  value = azurerm_application_security_group.consul_servers.id
}

output "consul_vmss" {
  value = local.vmss_name
}

output "consul_ip" {
  value = azurerm_public_ip.consul.ip_address
}

output "master_token" {
  value = random_uuid.consul_master_token.result
}

output "agent_server_token" {
  value = random_uuid.consul_agent_server_token.result
}

output "snapshot_token" {
  value = random_uuid.consul_snapshot_token.result
}

output "gossip_key" {
  value = random_id.consul_gossip_encryption_key.b64_std
}
