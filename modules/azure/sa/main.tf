resource "azurerm_storage_account" "this" {
  name                     = "satfstate${var.environment}"
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

    virtual_network_subnet_ids = var.subnet_ids
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate${var.environment}"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}