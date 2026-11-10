include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/public-ip"
}

dependency "rg" {
  config_path = "../01-rg/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name = "rg-devops-training-dev"
  }
}

# Order-only: the AKS identity looked up for the role assignment is
# created by 08-aks.
dependencies {
  paths = ["../08-aks"]
}

locals {
  env = "dev"
}

inputs = {
  resource_group_name = dependency.rg.outputs.name

  # Public frontend of the NGINX Gateway Fabric Gateway
  # (landing-zone/k8s/dev/04-nginx-gateway-fabric).
  name              = "pip-gw-${local.env}-training"
  domain_name_label = "gw-${local.env}-training"
  aks_identity_name = "id-aks-${local.env}-training"

  tags = {
    environment = local.env
    project     = "devops-training"
    role        = "gateway"
  }
}
