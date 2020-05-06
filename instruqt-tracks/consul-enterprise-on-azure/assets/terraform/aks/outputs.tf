output "frontend_client_certificate" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.client_certificate
}

output "frontend_kube_config" {
  value = azurerm_kubernetes_cluster.frontend.kube_config_raw
}

output "frontend_cluster_ca" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.cluster_ca_certificate
}

output "frontend_cluster_host" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.host
}

output "backend_client_certificate" {
  value = azurerm_kubernetes_cluster.backend.kube_config.0.client_certificate
}

output "backend_kube_config" {
  value = azurerm_kubernetes_cluster.backend.kube_config_raw
}

output "backend_cluster_ca" {
  value = azurerm_kubernetes_cluster.backend.kube_config.0.cluster_ca_certificate
}

output "backend_cluster_host" {
  value = azurerm_kubernetes_cluster.backend.kube_config.0.host
}
