include "root" {
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
      service_endpoints = ["Microsoft.storage"]
    },

    runner = {
      name             = "snet-${local.env}-runner"
      address_prefixes = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.storage"]
    },

    acr = {
      name             = "snet-${local.env}-acr"
      address_prefixes = ["10.10.3.0/24"]
      service_endpoints = ["Microsoft.ContainerRegistry"]
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
    },

    runner = {
      name = "nsg-${local.env}-runners"

      rules = {
        allow_ssh_from_my_ip = {
          name                       = "Allow-SSH-From-My-IP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = get_env("TF_VAR_my_ip")
          destination_address_prefix = "10.10.2.0/24"
        }

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
    },

    acr = {
      name = "nsg-${local.env}-acr"

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