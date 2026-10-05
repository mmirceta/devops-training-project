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

resource "azurerm_public_ip" "lz-bastion-pip" {
  name                = "pip-bas-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "lz-bastion" {
  name                = "bas-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.sku == "Standard" ? var.scale_units : null
  # Required for native-client features (az network bastion ssh/tunnel);
  # without it the CLI's bastion extension errors with a raw KeyError on
  # 'enableTunneling' since the API omits the field entirely.
  tunneling_enabled   = var.sku == "Standard" ? true : null

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.lz-bastion-pip.id
  }

  tags = var.tags
}
