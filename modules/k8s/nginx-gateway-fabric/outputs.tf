output "gateway_name" {
  value = var.gateway_name
}

output "gateway_namespace" {
  value = helm_release.nginx_gateway_fabric.namespace
}
