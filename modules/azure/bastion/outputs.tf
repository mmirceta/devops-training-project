output "bastion_host_id" {
  value = azurerm_bastion_host.lz-bastion.id
}

output "public_ip_address" {
  value = azurerm_public_ip.lz-bastion-pip.ip_address
}
