include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/azure/acr"
}

dependency "rg" {
  config_path = "../../../bootstrap/rg/"
}

dependency "network" {
  config_path = "../../../bootstrap/network"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  environment = "dev"

  sku           = "Premium"
  admin_enabled = false

  subnet_id = dependency.network.outputs.subnet_ids["mgmt"]
  vnet_id   = dependency.network.outputs.vnet_id

  tags = {
    environment = "dev"
    project     = "devops-training-project"
    managed_by  = "terragrunt"
  }
}
