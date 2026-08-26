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

resource "azurerm_private_dns_zone" "lz-dns-zone" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "lz-dns-zone-link" {
  for_each = var.vnet_ids

  name                  = "pdnslink-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.lz-dns-zone.name
  virtual_network_id    = each.value
  tags                  = var.tags
}
