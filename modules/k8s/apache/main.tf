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
          name  = "apache"
          image = var.image

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
