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

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.chart_version

  values = [yamlencode({
    crds = {
      enabled = true
    }

    # Gateway API shim: a Gateway annotated with
    # cert-manager.io/cluster-issuer gets a Certificate per HTTPS listener,
    # written to the Secret its certificateRefs point at. Needs the Gateway
    # API CRDs (installed by modules/k8s/nginx-gateway-fabric).
    config = {
      apiVersion = "controller.config.cert-manager.io/v1alpha1"
      kind       = "ControllerConfiguration"
      gatewayAPI = {
        enabled = true
      }
    }
  })]
}

# Cloudflare API token (Zone:DNS:Edit) used by the DNS-01 solver. Kept out
# of the issuers chart values so it never lands in a helm release record.
resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = helm_release.cert_manager.namespace
  }

  data = {
    api-token = var.cloudflare_api_token
  }
}

# ClusterIssuers live in a separate release (local chart in ./issuers):
# helm validates every manifest against the API before installing, so they
# can't share a release with the CRDs that define them, and
# kubernetes_manifest would need the CRDs to exist at plan time.
resource "helm_release" "cluster_issuers" {
  name      = "cluster-issuers"
  namespace = helm_release.cert_manager.namespace
  chart     = "${path.module}/issuers"

  values = [yamlencode({
    tokenSecretName = kubernetes_secret.cloudflare_api_token.metadata[0].name
    tokenSecretKey  = "api-token"
  })]

  depends_on = [helm_release.cert_manager]
}
