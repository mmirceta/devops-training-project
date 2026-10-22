include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/cloudflared"
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

# Order-only: the tunnel's public hostname points at the NGF Gateway
# service (gateway-nginx.nginx-gateway.svc), so it should exist first.
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

  # cloudflare_tunnel_token comes from TF_VAR_cloudflare_tunnel_token
  # (GitHub secret in CI) or the root terraform.tfvars locally.
}
