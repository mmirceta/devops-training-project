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
  # optional if already set via az CLI
  # subscription_id = "your-subscription-id"
}

resource "azurerm_resource_group" "lz-rg" {
  name     = "rg-${var.environment}-training"
  location = var.location
}