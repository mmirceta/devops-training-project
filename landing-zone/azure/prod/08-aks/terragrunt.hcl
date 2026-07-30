include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "prod" {
  path   = find_in_parent_folders("prod.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/cluster"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-prod"
  }
}

dependency "network" {
  config_path = "../02-network/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_ids = {
      mgmt = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-training/providers/Microsoft.Network/virtualNetworks/vnet-prod-training/subnets/snet-mgmt-prod"
      app  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-training/providers/Microsoft.Network/virtualNetworks/vnet-prod-training/subnets/snet-app-prod"
      data = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-training/providers/Microsoft.Network/virtualNetworks/vnet-prod-training/subnets/snet-data-prod"
      k8s  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-training/providers/Microsoft.Network/virtualNetworks/vnet-prod-training/subnets/snet-k8s-prod"
    }
  }
}

locals {
  env = "prod"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  subnet_id = dependency.network.outputs.subnet_ids["k8s"]

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
