include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/private-dns-zone"
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
    vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet"
  }
}

dependency "bootstrap_network" {
  config_path = "../../../bootstrap/02-network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-devops-training-bootstrap/providers/Microsoft.Network/virtualNetworks/lz-bootstrap-vnet"
  }
}

locals {
  env = "dev"
}

inputs = {
  name = "privatelink.westeurope.azmk8s.io"

  resource_group_name = dependency.rg.outputs.name

  vnet_ids = {
    dev       = dependency.network.outputs.vnet_id
    bootstrap = dependency.bootstrap_network.outputs.vnet_id
  }

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
