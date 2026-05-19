include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/azure/sa"
}

dependency "rg" {
  config_path = "../rg/"
}

dependency "network" {
  config_path = "../network/"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name
  environment = "devops"

  subnet_ids = [
    dependency.network.outputs.subnet_ids["state"]
  ]

  ip_rules = [
    "178.221.140.9"
  ]

  tags = {
    environment = "devops"
    managed_by  = "terragrunt"
    project     = "devops-training-project"
  }
}



# az storage container list \
#   --account-name YOUR_STORAGE_ACCOUNT_NAME \
#   --auth-mode login

