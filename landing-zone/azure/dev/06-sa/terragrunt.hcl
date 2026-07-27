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
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-dev"
  }
}

dependency "network" {
  config_path = "../02-network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_ids = {
      mgmt = "/subscriptions/d960facb-8e1a-44d3-be23-1c460b7077ee/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet/subnets/snet-mgmt-dev"
      app  = "/subscriptions/d960facb-8e1a-44d3-be23-1c460b7077ee/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet/subnets/snet-app-dev"
      data = "/subscriptions/d960facb-8e1a-44d3-be23-1c460b7077ee/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet/subnets/snet-data-dev"
    }
    vnet_id   = "/subscriptions/d960facb-8e1a-44d3-be23-1c460b7077ee/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/virtualNetworks/lz-dev-vnet"
    vnet_name = "lz-dev-vnet"
  }
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
