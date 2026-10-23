terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  host                   = var.host
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

# Cloudflare Tunnel connector removed: the Gateway now has a public IP
# instead (see landing-zone/azure/dev/12-gateway-pip). Resources are
# dropped here first so the apply destroys them; the module, the
# landing-zone unit and the tunnel token secret wiring go in a follow-up.
