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

resource "azurerm_container_registry" "lz-acr" {
  name                = "acr${var.env}training"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  network_rule_set {
    default_action = "Allow"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr" {
  for_each = var.role_assignments

  scope                = azurerm_container_registry.lz-acr.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}

resource "azurerm_private_dns_zone" "lz-acr-dns" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "lz-acr-dns-link" {
  name                  = "pdnslink-acr-${var.env}-training"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.lz-acr-dns.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "lz-acr-pe" {
  name                = "pe-acr-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-acr-${var.env}-training"
    private_connection_resource_id = azurerm_container_registry.lz-acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdnszg-acr-${var.env}-training"
    private_dns_zone_ids = [azurerm_private_dns_zone.lz-acr-dns.id]
  }

  tags = var.tags
}
