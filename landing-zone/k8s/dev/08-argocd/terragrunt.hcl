include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/argocd"
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

# Order-only: the UI's HTTPRoute needs the Gateway API CRDs and the shared
# Gateway (nginx-gateway-fabric); external-dns then publishes its hostname.
dependencies {
  paths = ["../04-nginx-gateway-fabric", "../06-external-dns"]
}

locals {
  env = "dev"
}

inputs = {
  host                    = dependency.aks.outputs.host
  client_certificate      = dependency.aks.outputs.client_certificate
  client_key              = dependency.aks.outputs.client_key
  cluster_ca_certificate  = dependency.aks.outputs.cluster_ca_certificate

  hostname = "argo.mapko.dev"

  # Side by side with Flux (07-flux, mmirceta/fluxcd): Argo CD syncs only
  # mmirceta/argocd, never apps Flux already manages.
  git_url  = "https://github.com/mmirceta/argocd"
  git_path = "dev"
}
