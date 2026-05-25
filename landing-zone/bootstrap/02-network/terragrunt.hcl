include "root"{
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/network"
}

dependency "rg" {
  config_path = "../01-rg"
}

locals {
  env = "bootstrap"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  address_space = ["10.10.0.0/16"]

  subnets = {
    state = {
      name             = "snet-${local.env}"
      address_prefixes = ["10.10.1.0/24"]
      service_endpoints = ["microsoft.storage"]
    }
  }

  nsgs = {
    state = {
      name = "nsg-${local.env}"

      rules = {
        deny_internet_inbound = {
          name                       = "Deny-Internet-Inbound"
          priority                   = 4000
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
      }
    }
  }

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}