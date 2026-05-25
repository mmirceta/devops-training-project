include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

terraform {
  source = "../../../../modules/azure/sa"
}

dependency "rg" {
  config_path = "../01-rg"
}

dependency "network" {
  config_path = "../02-network"
}

locals {
  my_ip       = get_env("TF_VAR_my_ip")
  my_ip_plain = replace(local.my_ip, "/32", "")
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  subnet_ids = [
    dependency.network.outputs.subnet_ids["data"]
  ]

  ip_rules = [
    local.my_ip_plain
  ]

}



# az storage container list \
#   --account-name YOUR_STORAGE_ACCOUNT_NAME \
#   --auth-mode login
