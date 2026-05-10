include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/sa"
}

dependency "rg" {
  config_path = "../rg"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name
  environment = "dev"

  subnet_ids = [
    dependency.network.outputs.subnet_ids["mgmt"]
  ]

  tags = {
    environment = "dev"
    managed_by  = "terragrunt"
    project     = "devops-training-project"
  }
}