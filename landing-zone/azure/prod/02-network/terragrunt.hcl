include "root"{
  path = find_in_parent_folders("root.hcl")
}

include "prod" {
  path   = find_in_parent_folders("prod.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/network"
}

dependency "rg" {
  config_path = "../01-rg"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-prod"
  }
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  address_space = ["10.30.0.0/16"]


    subnets = {
    app = {
      name             = "snet-app-prod"
      address_prefixes = ["10.30.1.0/24"]
    }

    data = {
      name             = "snet-data-prod"
      address_prefixes = ["10.30.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    mgmt = {
      name             = "snet-mgmt-prod"
      address_prefixes = ["10.30.3.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }
  }

  nsgs = {
    app = {
      name = "nsg-app-prod"

      rules = {
        allow_agw_https_to_app = {
          name                       = "Allow-AGW-HTTPS-To-App"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.30.3.0/24"
          destination_address_prefix = "10.30.1.0/24"
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
      name = "nsg-data-prod"

      rules = {
        allow_app_to_db = {
          name                       = "Allow-App-To-DB"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.30.1.0/24"
          destination_address_prefix = "10.30.2.0/24"
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
      name = "nsg-mgmt-prod"

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
          destination_address_prefix = "10.30.3.0/24"
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
  }

}