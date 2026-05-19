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

resource "azurerm_virtual_network" "lz-vnet" {
  name                = "lz-${var.environment}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags

}

resource "azurerm_subnet" "lz-subnet" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.lz-vnet.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints 

  depends_on = [ azurerm_virtual_network.lz-vnet ]
}

resource "azurerm_network_security_group" "lz-nsg" {
  for_each = var.nsgs

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  depends_on = [ azurerm_subnet.lz-subnet ]
}

##### by this point, it was without ai: 
##### [x] add dependency for nsg rules 

resource "azurerm_network_security_rule" "lz-nsg-rule" {
  for_each = merge([
    for nsg_key, nsg in var.nsgs : {
      for rule_key, rule in nsg.rules :
      "${nsg_key}-${rule_key}" => {
        nsg_name = nsg.name
        rule     = rule
      }
    }
  ]...)

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.nsg_name

  depends_on = [ azurerm_network_security_group.lz-nsg ]

}

resource "azurerm_subnet_network_security_group_association" "lz-subnet-nsg-association" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.lz-subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.lz-nsg[each.key].id

  depends_on = [ azurerm_network_security_group.lz-nsg ]
}