output "id" {
  value = azurerm_kubernetes_cluster.lz-aks.id
}

output "name" {
  value = azurerm_kubernetes_cluster.lz-aks.name
}

output "host" {
  value     = azurerm_kubernetes_cluster.lz-aks.kube_config[0].host
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.lz-aks.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.lz-aks.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.lz-aks.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.lz-aks.kube_config_raw
  sensitive = true
}
