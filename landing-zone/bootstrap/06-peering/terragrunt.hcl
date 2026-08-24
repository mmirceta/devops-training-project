include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/vnet-peering"
}

dependency "rg" {
  config_path = "../01-rg"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-bootstrap"
  }
}

dependency "network" {
  config_path = "../02-network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vnet_name = "lz-bootstrap-vnet"
  }
}

dependency "dev_network" {
  config_path = "../../azure/dev/02-network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet"
  }
}

inputs = {
  name = "peer-bootstrap-to-dev"

  resource_group_name  = dependency.rg.outputs.name
  virtual_network_name = dependency.network.outputs.vnet_name

  remote_virtual_network_id = dependency.dev_network.outputs.vnet_id
}
