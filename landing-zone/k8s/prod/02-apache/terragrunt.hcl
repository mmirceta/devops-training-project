include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "prod" {
  path   = find_in_parent_folders("prod.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/apache"
}

dependency "aks" {
  config_path = "../../../azure/prod/08-aks"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    host                    = "https://mock"
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
    cluster_ca_certificate = "bW9jaw=="
  }
}

locals {
  env = "prod"
}

inputs = {
  host                    = dependency.aks.outputs.host
  client_certificate      = dependency.aks.outputs.client_certificate
  client_key              = dependency.aks.outputs.client_key
  cluster_ca_certificate  = dependency.aks.outputs.cluster_ca_certificate
}
