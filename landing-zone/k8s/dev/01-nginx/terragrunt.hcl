include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/nginx"
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

# Order-only: the SecretProviderClass CRD (installed by the vault module's
# csi-secrets-store helm release) must exist before this module's
# kubernetes_manifest resource can be planned/applied. The "nginx"
# IngressClass (installed by the ingress-nginx helm release) must exist
# before this module's Ingress resource can be planned/applied.
dependencies {
  paths = ["../03-vault", "../00-ingress-nginx"]
}

locals {
  env = "dev"
}

inputs = {
  host                    = dependency.aks.outputs.host
  client_certificate      = dependency.aks.outputs.client_certificate
  client_key              = dependency.aks.outputs.client_key
  cluster_ca_certificate  = dependency.aks.outputs.cluster_ca_certificate

  image = "acrbootstraptraining.azurecr.io/nginx:latest"
}
