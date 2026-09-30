include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/cluster"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-dev"
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
      k8s  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-training/providers/Microsoft.Network/virtualNetworks/vnet-dev-training/subnets/snet-k8s-dev"
    }
  }
}

dependency "aks_dns" {
  config_path = "../07a-aks-dns/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-devops-training-dev/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
  }
}

locals {
  env = "dev"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  env = local.env

  subnet_id = dependency.network.outputs.subnet_ids["k8s"]

  private_cluster_enabled = true
  private_dns_zone_id     = dependency.aks_dns.outputs.id

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
