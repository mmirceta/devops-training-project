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
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
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

# Gateway API CRDs (standard channel) are not shipped in the NGF chart and
# must exist before it installs, since the chart itself creates a
# GatewayClass and Gateway. Version must match what the NGF release expects
# (config/crd/gateway-api/standard/kustomization.yaml in the NGF repo).
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml"
}

locals {
  gateway_api_manifests = {
    for m in provider::kubernetes::manifest_decode_multi(data.http.gateway_api_crds.response_body) :
    "${m.kind}/${m.metadata.name}" => m
  }
}

resource "kubernetes_manifest" "gateway_api_crds" {
  for_each = local.gateway_api_manifests
  manifest = each.value
}

locals {
  # Internal: LB frontend in the AKS node subnet, reachable only from inside
  # the VNet (Bastion tunnel, runner). Public: frontend on a pre-created
  # static public IP outside the MC_* node resource group. The internal
  # annotation is always set explicitly so switching modes never relies on
  # an old annotation being removed.
  service_annotations = merge(
    { "service.beta.kubernetes.io/azure-load-balancer-internal" = tostring(var.load_balancer_internal) },
    var.load_balancer_internal && var.load_balancer_ip != null ? { "service.beta.kubernetes.io/azure-load-balancer-ipv4" = var.load_balancer_ip } : {},
    !var.load_balancer_internal && var.public_ip_name != null ? { "service.beta.kubernetes.io/azure-pip-name" = var.public_ip_name } : {},
    !var.load_balancer_internal && var.public_ip_resource_group != null ? { "service.beta.kubernetes.io/azure-load-balancer-resource-group" = var.public_ip_resource_group } : {},
  )
}

resource "helm_release" "nginx_gateway_fabric" {
  name             = "nginx-gateway-fabric"
  namespace        = "nginx-gateway"
  create_namespace = true
  repository       = "oci://ghcr.io/nginx/charts"
  chart            = "nginx-gateway-fabric"
  version          = var.chart_version

  values = [yamlencode({
    nginxGateway = {
      gatewayClassName = var.gateway_class_name
    }

    nginx = {
      service = {
        # Same reasoning as ingress-nginx: "Local" gives Azure a dedicated
        # healthCheckNodePort to probe, decoupled from HTTP routing.
        externalTrafficPolicy = "Local"

        patches = [{
          type = "StrategicMerge"
          value = {
            metadata = {
              annotations = local.service_annotations
            }
          }
        }]
      }
    }

    # One shared Gateway; apps attach HTTPRoutes to it from their own
    # namespaces (see modules/k8s/nginx and modules/k8s/apache).
    gateways = [{
      name      = var.gateway_name
      namespace = "nginx-gateway"
      spec = {
        gatewayClassName = var.gateway_class_name
        listeners = [{
          name     = "http"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = { from = "All" }
          }
        }]
      }
    }]
  })]

  depends_on = [kubernetes_manifest.gateway_api_crds]
}
