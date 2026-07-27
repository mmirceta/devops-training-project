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

resource "azurerm_kubernetes_cluster" "lz-aks" {
  name                = "aks-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.env}-training"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled = false

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = var.subnet_id
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "lz-aks-applications" {
  name                  = "applications"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.lz-aks.id
  mode                  = "User"
  vm_size               = var.applications_node_vm_size
  node_count            = var.applications_node_count
  vnet_subnet_id        = var.subnet_id

  tags = var.tags
}
