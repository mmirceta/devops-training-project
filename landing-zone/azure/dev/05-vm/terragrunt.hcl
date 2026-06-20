include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/vm"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-dev-training"
  }
}

dependency "network" {
  config_path = "../02-network/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_ids = {
      mgmt = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-mgmt-dev"
      app  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-app-dev"
      data = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-data-dev"
    }
    vnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training"
    vnet_name = "vnet-dev-training"
  }
}

# dependency "acr" {
#   config_path = "../04-acr/"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.ContainerRegistry/registries/acrdevtrainingmm"
#     name                = "acrdevtrainingmm"
#     login_server        = "acrdevtrainingmm.azurecr.io"
#     private_endpoint_ip = "10.20.3.4"
#   }
# }

locals {
  env = "dev"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env
  name        = "acr-test"
  location    = "westeurope"

  subnet_id = dependency.network.outputs.subnet_ids["mgmt"]

  size = "Standard_D2s_v3"
  zone = "3"

  admin_username = "azureuser"
  admin_password = get_env("TF_VAR_vm_admin_password")

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
