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

resource "azurerm_storage_account" "this" {
  name                     = "sa${var.env}trainingmm"
  resource_group_name      = var.resource_group_name
  location                 = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"

    bypass = [
      "AzureServices"
    ]

    ip_rules = var.ip_rules 

    virtual_network_subnet_ids = var.subnet_ids
  }

  tags = var.tags
}

resource "azurerm_management_lock" "this" {
  count      = var.enable_lock ? 1 : 0
  name       = "lock-${azurerm_storage_account.this.name}"
  scope      = azurerm_storage_account.this.id
  lock_level = "CanNotDelete"
}

resource "azurerm_storage_container" "this" {
  for_each = toset(var.containers)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}