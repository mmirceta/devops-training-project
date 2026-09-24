output "namespace" {
  value = kubernetes_namespace.vault.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.vault.metadata[0].name
}
