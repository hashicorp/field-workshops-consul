# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "consul_root_token" {
  value     = local.hcp_acl_token_secret_id
  sensitive = true
}

output "consul_url" {
  value = local.hcp_consul_cluster.public_endpoint ? (
    local.hcp_consul_cluster.consul_public_endpoint_url
    ) : (
    local.hcp_consul_cluster.consul_private_endpoint_url
  )
}

output "kubeconfig_filename" {
  value = abspath(module.eks.kubeconfig_filename)
}

#output "hashicups_url" {
#  value = module.demo_app.hashicups_url
#}

output "next_steps" {
  value = "Hashicups Application will be ready in ~2 minutes. Use 'terraform output consul_root_token' to retrieve the root token."
}

output "eks_dev_cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "helm_chart" {
  value = module.eks_consul_client.helm_chart
}