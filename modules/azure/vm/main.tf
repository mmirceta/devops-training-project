terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
}

resource "azurerm_public_ip" "lz-vm-pip" {
  name                = "pip-${var.name}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : []

  tags = var.tags
}

resource "azurerm_network_interface" "lz-vm-nic" {
  name                = "nic-${var.name}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lz-vm-pip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "lz-vm" {
  name                            = "vm-${var.name}-${var.env}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.size
  zone                            = var.zone
  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password                  = var.admin_password

  network_interface_ids = [azurerm_network_interface.lz-vm-nic.id]
  custom_data           = var.custom_data != null ? var.custom_data : filebase64("${path.module}/cloud-init.yaml")

  depends_on = [azurerm_network_interface.lz-vm-nic]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}
