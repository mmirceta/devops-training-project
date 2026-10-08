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

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }

  # Without this, Azure's cloud provider health-probes the LoadBalancer
  # backend on the same port/path (80, "/") that serves real traffic.
  # Since no Ingress rule matches bare "/", the controller's default
  # backend returns 404, the probe reads that as unhealthy, and the LB
  # silently drops all traffic (hangs, not a clean rejection) even
  # though the backend itself is fine. "Local" makes Kubernetes expose
  # a dedicated healthCheckNodePort that Azure probes instead, decoupled
  # from Ingress routing entirely.
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}
