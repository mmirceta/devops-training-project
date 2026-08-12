include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/acr"
}

dependency "rg" {
  config_path = "../01-rg/"
}

locals {
  env = "bootstrap"
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

# dependency "aks" {
#   config_path = "../08-aks/"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     kubelet_identity_object_id = "00000000-0000-0000-0000-000000000000"
#   }
# }


inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  sku           = "Premium"
  admin_enabled = false

  subnet_id = dependency.network.outputs.subnet_ids["acr"]
  vnet_id   = dependency.network.outputs.vnet_id

  tags = {
    environment = local.env
    project     = "devops-training"
  }

  role_assignments = {
    dev-sp-pull = {
      principal_id = "73797b07-b519-4620-9394-a8112ecba828"
      role         = "AcrPull"
    },
    dev-sp-push = {
      principal_id = "73797b07-b519-4620-9394-a8112ecba828"
      role         = "AcrPush"
    },
    prod-sp-pull = {
      principal_id = "f8d2f62a-8897-4ab5-aa7a-b407ec626c0d"
      role         = "AcrPull"
    }
  }
}
