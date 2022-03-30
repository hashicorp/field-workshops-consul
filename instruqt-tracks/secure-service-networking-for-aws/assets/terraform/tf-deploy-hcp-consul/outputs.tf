output "aws_vpc_eks_dev_id" {
  value = "${module.vpc_eks_dev.vpc_id}"
}
output "eks_dev_private_subnets" {
  value = "${module.vpc_eks_dev.private_subnets}"
}
output "eks_dev_public_subnets" {
  value = "${module.vpc_eks_dev.public_subnets}"
}
output "aws_vpc_eks_prod_id" {
  value = "${module.vpc_eks_prod.vpc_id}"
}
output "eks_prod_private_subnets" {
  value = "${module.vpc_eks_prod.private_subnets}"
}
output "eks_prod_public_subnets" {
  value = "${module.vpc_eks_prod.public_subnets}"
}
output "aws_vpc_ecs_id" {
  value = "${module.vpc_services_ecs.vpc_id}"
}
output "ecs_private_subnets" {
  value = "${module.vpc_services_ecs.private_subnets}"
}
output "ecs_public_subnets" {
  value = "${module.vpc_services_ecs.public_subnets}"
}
output "eks_prod_public_route_table_ids" {
  value = "${module.vpc_eks_prod.public_route_table_ids}"
}
output "eks_dev_public_route_table_ids" {
  value = "${module.vpc_eks_dev.public_route_table_ids}"
}
output "ecs_public_route_table_ids" {
  value = "${module.vpc_services_ecs.public_route_table_ids}"
}
output "ecs_private_route_table_ids" {
  value = "${module.vpc_services_ecs.private_route_table_ids}"
}
output "hcp_consul_cluster" {
  value = "${hcp_consul_cluster.workshop_hcp_consul}"
  sensitive = true
}
output "hcp_cluster_id" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.cluster_id}"
}
output "hcp_consul_public_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_public_endpoint_url}"
}
output "hcp_consul_private_endpoint_url" {
  value = "${hcp_consul_cluster.workshop_hcp_consul.consul_private_endpoint_url}"
}
output "hcp_consul_config_file" {
  value = hcp_consul_cluster.workshop_hcp_consul.consul_config_file
}
output "consul_datacenter" {
  value = hcp_consul_cluster.workshop_hcp_consul.datacenter
}
output "hcp_consul_version" {
  value = hcp_consul_cluster.workshop_hcp_consul.consul_version
}
output "hcp_consul_ca_file" {
  value = hcp_consul_cluster.workshop_hcp_consul.consul_ca_file
}
output "hcp_acl_token" {
  value = hcp_consul_cluster_root_token.token
  sensitive = true
}
output "hcp_acl_token_secret_id" {
  value = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}
output "vpc_region" {
  value = data.aws_region.current
}
output "hcp_hvn" {
  value = hcp_hvn.workshop_hvn
}
