terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# Flux controllers and CRDs. Only source-controller (fetches the git repo)
# and kustomize-controller (applies it) are needed to sync plain manifests;
# the rest stay off to save requests on the applications node pool. Enable
# helmController for HelmReleases, notificationController for alerts, and
# the image* controllers for image update automation.
resource "helm_release" "flux" {
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  version          = var.chart_version

  values = [yamlencode({
    sourceController          = { create = true }
    kustomizeController       = { create = true }
    helmController            = { create = false }
    notificationController    = { create = false }
    imageAutomationController = { create = false }
    imageReflectionController = { create = false }
  })]
}

# The flux-system GitRepository + Kustomization that point Flux at the
# GitOps repo. Rendered through the flux2-sync chart instead of
# kubernetes_manifest, which would need the Flux CRDs to exist at plan time.
# Public repo over HTTPS, so no credentials Secret.
resource "helm_release" "flux_sync" {
  name       = "flux-system"
  namespace  = helm_release.flux.namespace
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"
  version    = var.sync_chart_version

  values = [yamlencode({
    gitRepository = {
      spec = {
        url      = var.git_url
        ref      = { branch = var.git_branch }
        interval = "1m"
      }
    }

    kustomization = {
      spec = {
        path     = var.git_path
        interval = "10m"
        # Objects removed from git are deleted from the cluster.
        prune   = true
        wait    = true
        timeout = "5m"
      }
    }
  })]
}
