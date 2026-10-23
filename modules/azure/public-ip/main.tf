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

resource "azurerm_public_ip" "lz-pip" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  # Gives the IP a stable <label>.<region>.cloudapp.azure.com name, so DNS
  # records elsewhere (Cloudflare) can CNAME to it.
  domain_name_label = var.domain_name_label

  tags = var.tags
}

# The AKS cloud provider attaches this IP to the cluster's LoadBalancer, but
# it lives outside the MC_* node resource group, so the cluster identity
# needs read/join rights on it.
#
# The CI service principal only has Contributor and cannot create role
# assignments, so this must be applied locally (as Owner) before the CI
# apply that switches the gateway Service to this IP:
#   terragrunt apply   (in landing-zone/azure/dev/12-gateway-pip)
data "azurerm_user_assigned_identity" "aks" {
  count = var.aks_identity_name != null ? 1 : 0

  name                = var.aks_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "lz-pip-aks-network" {
  count = var.aks_identity_name != null ? 1 : 0

  scope                = azurerm_public_ip.lz-pip.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks[0].principal_id
}
