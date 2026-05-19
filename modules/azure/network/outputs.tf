output "vnet_id" {
  value = azurerm_virtual_network.lz-vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.lz-vnet.name
}

output "subnet_ids" {
  value = {
    for key, subnet in azurerm_subnet.lz-subnet : key => subnet.id
  }
}

