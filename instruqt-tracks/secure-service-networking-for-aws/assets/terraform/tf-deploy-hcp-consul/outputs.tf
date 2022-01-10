output "aws_vpc_id" {
  value = "${aws_vpc.vpc_services.id}"
}
output "hcp_consul_public_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
}
output "hcp_consul_private_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
}
output "hcp_consul_config_file_decoded" {
  value = "${base64decode(hcp_consul_cluster.workshop_hcp_consul.consul_config_file)}"
}
output "hcp_consul_config_file" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_config_file}"
}
output "consul_datacenter" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.datacenter}"
}
output "hcp_consul_version" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_version}"
}

#output "vpc_ecs" {
#  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
#}