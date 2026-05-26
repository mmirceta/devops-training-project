output "id" {
  value = azurerm_container_registry.lz-acr.id
}

output "login_server" {
  value = azurerm_container_registry.lz-acr.login_server
}

output "name" {
  value = azurerm_container_registry.lz-acr.name
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.lz-acr-pe.private_service_connection[0].private_ip_address
}
