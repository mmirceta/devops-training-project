include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/azure/vm"
}

dependency "rg" {
  config_path = "../01-rg/"
}

dependency "network" {
  config_path = "../02-network/"
}

dependency "acr" {
  config_path = "../04-acr/"
}

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
