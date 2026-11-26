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

# Argo CD next to Flux, as a side-by-side comparison. The two must never
# manage the same objects: Flux owns nginx, apache and Headlamp
# (mmirceta/fluxcd), Argo CD only what is in its own repo.
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version

  values = [yamlencode({
    global = {
      domain = var.hostname
    }

    configs = {
      params = {
        # TLS ends at the shared Gateway (wildcard *.mapko.dev cert), so
        # argocd-server serves plain HTTP behind it. The argocd CLI then
        # needs --grpc-web, because the HTTPRoute carries HTTP only.
        "server.insecure" = true
      }
    }

    # No SSO (Dex) and no notifications for now: login is the built-in
    # admin user, whose initial password is in the
    # argocd-initial-admin-secret Secret.
    dex           = { enabled = false }
    notifications = { enabled = false }

    # Small requests: the single applications node already runs Flux and
    # Headlamp.
    controller = {
      resources = { requests = { cpu = "50m", memory = "256Mi" } }
    }
    repoServer = {
      resources = { requests = { cpu = "25m", memory = "128Mi" } }
    }
    applicationSet = {
      resources = { requests = { cpu = "10m", memory = "64Mi" } }
    }
    redis = {
      resources = { requests = { cpu = "10m", memory = "64Mi" } }
    }

    server = {
      resources = { requests = { cpu = "25m", memory = "128Mi" } }

      # Public UI on the shared Gateway, HTTPS listener only so the admin
      # password never travels over plain HTTP. external-dns creates the
      # DNS record from the hostname.
      httproute = {
        enabled = true
        parentRefs = [{
          name        = "gateway"
          namespace   = "nginx-gateway"
          sectionName = "https"
        }]
        hostnames = [var.hostname]
      }
    }
  })]
}

# Root Application pointing Argo CD at its GitOps repo. Rendered through
# the argocd-apps chart instead of kubernetes_manifest, which would need
# the Application CRD to exist at plan time (same reason Flux uses
# flux2-sync). Public repo over HTTPS, so no repository credentials.
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  namespace  = helm_release.argocd.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.apps_chart_version

  values = [yamlencode({
    applications = {
      root = {
        namespace = helm_release.argocd.namespace
        project   = "default"
        source = {
          repoURL        = var.git_url
          targetRevision = var.git_branch
          path           = var.git_path
          # Top-level files only: <env>/ holds the child Applications
          # (<env>/<app>.yaml) next to each app's own manifest folder
          # (<env>/<app>/), which only that app's Application syncs.
          directory = { recurse = false }
        }
        destination = {
          server = "https://kubernetes.default.svc"
        }
        syncPolicy = {
          # Like Flux's prune: objects removed from git are deleted from
          # the cluster, and manual changes are reverted.
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  })]
}
