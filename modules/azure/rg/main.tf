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

resource "azurerm_resource_group" "lz-rg" {
  name     = "rg-devops-training-${var.env}"
  location = var.location
}

