include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path   = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/k8s/nginx-gateway-fabric"
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

# Static public IP (+ the AKS identity's role on it) for the Gateway's
# LoadBalancer.
dependency "gateway_pip" {
  config_path = "../../../azure/dev/12-gateway-pip"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    name                = "pip-gw-dev-training"
    resource_group_name = "rg-devops-training-dev"
  }
}

locals {
  env = "dev"
}

inputs = {
  host                    = dependency.aks.outputs.host
  client_certificate      = dependency.aks.outputs.client_certificate
  client_key              = dependency.aks.outputs.client_key
  cluster_ca_certificate  = dependency.aks.outputs.cluster_ca_certificate
  # Public LB frontend on pip-gw-dev-training
  # (gw-dev-training.westeurope.cloudapp.azure.com). Inbound 80/443 is
  # allowed on nsg-k8s-dev.
  load_balancer_internal   = false
  public_ip_name           = dependency.gateway_pip.outputs.name
  public_ip_resource_group = dependency.gateway_pip.outputs.resource_group_name

  # HTTPS for every *.mapko.dev host; cert-manager (05-cert-manager) issues
  # the wildcard certificate via DNS-01 on Cloudflare and keeps it renewed.
  https_hostname           = "*.mapko.dev"
  https_certificate_secret = "wildcard-mapko-dev-tls"
  gateway_annotations = {
    "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
  }
}
