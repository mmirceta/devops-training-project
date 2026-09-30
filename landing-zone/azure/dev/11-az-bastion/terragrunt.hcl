include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/bastion"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-dev"
  }
}

dependency "network" {
  config_path = "../02-network/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_ids = {
      bastion = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/AzureBastionSubnet"
    }
  }
}

locals {
  env = "dev"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  subnet_id = dependency.network.outputs.subnet_ids["bastion"]

  tags = {
    environment = local.env
    project     = "devops-training"
    role        = "bastion"
  }
}
