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

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "kv${var.env}devopstraining"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  enable_rbac_authorization = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.subnet_ids
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "pdnslink-kv-${var.env}-training"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "this" {
  name                = "pe-kv-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-kv-${var.env}-training"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdnszg-kv-${var.env}-training"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }

  tags = var.tags
}
