include "root"{
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/network"
}

dependency "rg" {
  config_path = "../01-rg"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-dev"
  }
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  address_space = ["10.20.0.0/16"]


    subnets = {
    app = {
      name             = "snet-app-dev"
      address_prefixes = ["10.20.1.0/24"]
    }

    data = {
      name             = "snet-data-dev"
      address_prefixes = ["10.20.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    mgmt = {
      name             = "snet-mgmt-dev"
      address_prefixes = ["10.20.3.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }

    k8s = {
      name             = "snet-k8s-dev"
      address_prefixes = ["10.20.4.0/24"]
    }

    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.20.5.0/26"]
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
          source_address_prefix      = "10.20.3.0/24"
          destination_address_prefix = "10.20.1.0/24"
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
          source_address_prefix      = "10.20.1.0/24"
          destination_address_prefix = "10.20.2.0/24"
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
        allow_ssh_from_my_ip = {
          name                       = "Allow-SSH-From-My-IP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = get_env("TF_VAR_my_ip")
          destination_address_prefix = "10.20.3.0/24"
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

    k8s = {
      name = "nsg-k8s-dev"

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

    # Mandatory NSG rules for AzureBastionSubnet, per Azure Bastion's documented
    # requirements: https://learn.microsoft.com/azure/bastion/bastion-nsg
    bastion = {
      name = "nsg-bastion-dev"

      rules = {
        allow_https_inbound = {
          name                       = "AllowHttpsInBound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = get_env("TF_VAR_my_ip")
          destination_address_prefix = "*"
        }

        allow_gateway_manager_inbound = {
          name                       = "AllowGatewayManagerInBound"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "GatewayManager"
          destination_address_prefix = "*"
        }

        allow_azure_lb_inbound = {
          name                       = "AllowAzureLoadBalancerInBound"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
        }

        allow_bastion_comm_8080_inbound = {
          name                       = "AllowBastionHostCommunication-8080-Inbound"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }

        allow_bastion_comm_5701_inbound = {
          name                       = "AllowBastionHostCommunication-5701-Inbound"
          priority                   = 140
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "5701"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
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

        allow_ssh_outbound = {
          name                       = "AllowSshRdpOutBound-22"
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "VirtualNetwork"
        }

        allow_rdp_outbound = {
          name                       = "AllowSshRdpOutBound-3389"
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "*"
          destination_address_prefix = "VirtualNetwork"
        }

        allow_azure_cloud_outbound = {
          name                       = "AllowAzureCloudOutBound"
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "AzureCloud"
        }

        allow_bastion_comm_8080_outbound = {
          name                       = "AllowBastionHostCommunication-8080-Outbound"
          priority                   = 130
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }

        allow_bastion_comm_5701_outbound = {
          name                       = "AllowBastionHostCommunication-5701-Outbound"
          priority                   = 140
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "5701"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }

        allow_http_outbound = {
          name                       = "AllowHttpOutBound"
          priority                   = 150
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "Internet"
        }
      }
    }
  }

}