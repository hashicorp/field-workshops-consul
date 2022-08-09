output "helm_chart" {
    value = base64encode(templatefile("${path.module}/templates/consul.tpl", {
      datacenter       = var.datacenter
      consul_hosts     = jsonencode(var.consul_hosts)
      cluster_id       = var.cluster_id
      k8s_api_endpoint = var.k8s_api_endpoint
      consul_version   = substr(var.consul_version, 1, -1)
    }))
}
