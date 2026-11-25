output "namespace" {
  value = helm_release.argocd.namespace
}

output "url" {
  value = "https://${var.hostname}"
}
