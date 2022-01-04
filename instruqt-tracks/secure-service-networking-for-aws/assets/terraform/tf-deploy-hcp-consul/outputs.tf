output "hcp_consul_public_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
}
output "hcp_consul_config_file" {
  value = "${base64decode(hcp_consul_cluster.workshop_hcp_consul.consul_config_file)}"
}
output "hcp_consul_version" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_version}"
}

#output "vpc_ecs" {
#  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
#}