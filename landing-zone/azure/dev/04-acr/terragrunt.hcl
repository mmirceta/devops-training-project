include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/azure/acr"
}

dependency "rg" {
  config_path = "../01-rg/"
}

dependency "network" {
  config_path = "../02-network/"
}

locals {
  env = "dev"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  sku           = "Premium"
  admin_enabled = false

  subnet_id = dependency.network.outputs.subnet_ids["mgmt"]
  vnet_id   = dependency.network.outputs.vnet_id

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
