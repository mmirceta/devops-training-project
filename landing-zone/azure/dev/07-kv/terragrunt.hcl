include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/kv"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-dev-training"
  }
}

dependency "network" {
  config_path = "../02-network/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_ids = {
      mgmt = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-mgmt-dev"
      app  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-app-dev"
      data = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-data-dev"
    }
    vnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training"
    vnet_name = "vnet-dev-training"
  }
}

locals {
  my_ip       = get_env("TF_VAR_my_ip")
  my_ip_plain = replace(local.my_ip, "/32", "")
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  subnet_id  = dependency.network.outputs.subnet_ids["mgmt"]
  subnet_ids = [dependency.network.outputs.subnet_ids["mgmt"]]
  vnet_id    = dependency.network.outputs.vnet_id

  ip_rules = [local.my_ip_plain]

}
