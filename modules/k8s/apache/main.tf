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

resource "kubernetes_namespace" "apache" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "apache" {
  metadata {
    name      = "apache"
    namespace = kubernetes_namespace.apache.metadata[0].name
    labels = {
      app = "apache"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "apache"
      }
    }

    template {
      metadata {
        labels = {
          app = "apache"
        }
      }

      spec {
        node_selector = {
          "kubernetes.azure.com/agentpool" = "applications"
        }

        container {
          name              = "apache"
          image             = var.image
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "apache" {
  metadata {
    name      = "apache"
    namespace = kubernetes_namespace.apache.metadata[0].name
  }

  spec {
    selector = {
      app = "apache"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Requires modules/k8s/ingress-nginx to already be deployed on the cluster
# (provides the "nginx" IngressClass this references).
resource "kubernetes_ingress_v1" "apache" {
  metadata {
    name      = "apache"
    namespace = kubernetes_namespace.apache.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/apache(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.apache.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
