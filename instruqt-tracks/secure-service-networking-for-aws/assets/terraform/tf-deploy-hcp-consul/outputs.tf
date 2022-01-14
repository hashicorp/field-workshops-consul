output "aws_vpc_id" {
  value = "${module.vpc.vpc_id}"
}
output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}
output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}
output "hcp_consul_public_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
}
output "hcp_consul_private_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_private_endpoint_url}"
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

output "hcp_consul_ca_file" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_ca_file}"
}

#output "vpc_ecs" {
#  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
#}