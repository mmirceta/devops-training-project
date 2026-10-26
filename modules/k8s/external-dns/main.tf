terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
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

provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

# Same Cloudflare token cert-manager uses; external-dns additionally needs
# Zone:Zone:Read to look up the zone.
resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    api-token = var.cloudflare_api_token
  }
}

# Watches HTTPRoutes: every spec.hostnames entry becomes a record pointing
# at the address of the Gateway the route is attached to (status.addresses),
# plus a TXT record marking it as owned by txt_owner_id.
resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = var.chart_version

  values = [yamlencode({
    provider = {
      name = "cloudflare"
    }

    sources       = ["gateway-httproute"]
    domainFilters = var.domain_filters
    policy        = var.policy
    registry      = "txt"
    txtOwnerId    = var.txt_owner_id

    env = [{
      name = "CF_API_TOKEN"
      valueFrom = {
        secretKeyRef = {
          name = kubernetes_secret.cloudflare_api_token.metadata[0].name
          key  = "api-token"
        }
      }
    }]
  })]
}
