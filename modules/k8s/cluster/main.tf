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

resource "azurerm_user_assigned_identity" "lz-aks" {
  name                = "id-aks-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_kubernetes_cluster" "lz-aks" {
  name                = "aks-${var.env}-training"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.env}-training"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled = false #change to true if you want to enable private cluster

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = var.subnet_id
    only_critical_addons_enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.lz-aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
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

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "lz-aks-node-rg-network" {
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/MC_${var.resource_group_name}_aks-${var.env}-training_${lower(replace(var.location, " ", ""))}"
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.lz-aks.principal_id

  depends_on = [azurerm_kubernetes_cluster.lz-aks]
}
