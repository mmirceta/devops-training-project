include "root"{
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/network"
}

dependency "rg" {
  config_path = "../rg"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  environment = "dev"

  address_space = ["10.10.0.0/16"]

##### by this point, it was without ai: 
##### fix: add dependency (nsg) for rules
    subnets = {
    app = {
      name             = "snet-app-dev"
      address_prefixes = ["10.10.1.0/24"]
    }

    data = {
      name             = "snet-data-dev"
      address_prefixes = ["10.10.2.0/24"]
    }

    mgmt = {
      name             = "snet-mgmt-dev"
      address_prefixes = ["10.10.3.0/24"]
    }
  }

  nsgs = {
    app = {
      name = "nsg-app-dev"

      rules = {
        allow_agw_https_to_app = {
          name                       = "Allow-AGW-HTTPS-To-App"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.10.3.0/24"
          destination_address_prefix = "10.10.1.0/24"
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
    }

    data = {
      name = "nsg-data-dev"

      rules = {
        allow_app_to_db = {
          name                       = "Allow-App-To-DB"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.10.1.0/24"
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
    }

    mgmt = {
      name = "nsg-mgmt-dev"

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
    environment = "dev"
    project     = "devops-training-project"
    managed_by  = "terragrunt"
  }
}