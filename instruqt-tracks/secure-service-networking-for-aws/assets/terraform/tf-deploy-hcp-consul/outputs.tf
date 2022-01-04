output "hcp_consul_public_endpoint_url" {
  value = "${hcp_consul_cluster.learn_hcp.consul_public_endpoint_url}"
}
output "hcp_consul_config_file" {
  value = "${base64decode(hcp_consul_cluster.learn_hcp.consul_config_file)}"
}
output "hcp_consul_version" {
  value = "${hcp_consul_cluster.learn_hcp.consul_version}"
}

#output "vpc_ecs" {
#  value = "${hcp_consul_cluster.learn_hcp.consul_public_endpoint_url}"
#}