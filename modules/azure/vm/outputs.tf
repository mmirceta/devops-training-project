output "public_ip" {
  value = azurerm_public_ip.lz-vm-pip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.lz-vm-nic.private_ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.lz-vm.name
}
