output "frontend_client_certificate" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.client_certificate
}

output "frontend_kube_config" {
  value = azurerm_kubernetes_cluster.frontend.kube_config_raw
}

output "backend_client_certificate" {
  value = azurerm_kubernetes_cluster.backend.kube_config.0.client_certificate
}

output "backend_kube_config" {
  value = azurerm_kubernetes_cluster.backend.kube_config_raw
}
