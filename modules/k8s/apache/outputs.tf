output "service_name" {
  value = kubernetes_service.apache.metadata[0].name
}

output "namespace" {
  value = kubernetes_service.apache.metadata[0].namespace
}
