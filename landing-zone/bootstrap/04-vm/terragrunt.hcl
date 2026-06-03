include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vm"
}

dependency "rg" {
  config_path = "../01-rg/"
}

dependency "network" {
  config_path = "../02-network/"
}

locals {
  env = "bootstrap"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env
  name        = "vm-${local.env}"
  location    = "westeurope"

  subnet_id = dependency.network.outputs.subnet_ids["runner"]

  size = "Standard_D2s_v3"
  zone = "3"

  admin_username = "azureuser"
  admin_password = get_env("TF_VAR_vm_admin_password")

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}