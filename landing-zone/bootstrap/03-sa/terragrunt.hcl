include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/sa"
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

  subnet_ids = [
    dependency.network.outputs.subnet_ids["state"]
  ]

  ip_rules = [
    get_env("TF_VAR_my_ip")
  ]

  containers = [
    "tfstate-bootstrap",
    "tfstate-dev",
    "tfstate-prod"
  ]

  enable_lock = true

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}



# az storage container list \
#   --account-name YOUR_STORAGE_ACCOUNT_NAME \
#   --auth-mode login

