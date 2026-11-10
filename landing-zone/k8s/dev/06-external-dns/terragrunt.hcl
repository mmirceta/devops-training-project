include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/external-dns"
}

dependency "aks" {
  config_path = "../../../azure/dev/08-aks"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    host                    = "https://mock"
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
    cluster_ca_certificate = "bW9jaw=="
  }
}

# Order-only: external-dns watches HTTPRoutes and Gateways, so the Gateway
# API CRDs (installed by nginx-gateway-fabric) must exist when it starts.
dependencies {
  paths = ["../04-nginx-gateway-fabric"]
}

locals {
  env = "dev"
}

inputs = {
  host                    = dependency.aks.outputs.host
  client_certificate      = dependency.aks.outputs.client_certificate
  client_key              = dependency.aks.outputs.client_key
  cluster_ca_certificate  = dependency.aks.outputs.cluster_ca_certificate

  domain_filters = ["mapko.dev"]
  txt_owner_id   = "aks-dev-training"

  # cloudflare_api_token comes from TF_VAR_cloudflare_api_token
  # (GitHub secret in CI) or the root terraform.tfvars locally.
}
