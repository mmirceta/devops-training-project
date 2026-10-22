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

# Outbound-only Cloudflare Tunnel connector. The tunnel itself and its
# public hostname -> service mapping are managed by hand in the Cloudflare
# Zero Trust dashboard (remotely-managed tunnel); this only runs the
# connector that dials out to Cloudflare, so nothing in the cluster needs
# a public IP or an inbound NSG rule.
resource "kubernetes_namespace" "cloudflared" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "tunnel_token" {
  metadata {
    name      = "cloudflared-tunnel-token"
    namespace = kubernetes_namespace.cloudflared.metadata[0].name
  }

  data = {
    token = var.cloudflare_tunnel_token
  }
}

resource "kubernetes_deployment" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = kubernetes_namespace.cloudflared.metadata[0].name
    labels = {
      app = "cloudflared"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "cloudflared"
      }
    }

    template {
      metadata {
        labels = {
          app = "cloudflared"
        }
      }

      spec {
        node_selector = {
          "kubernetes.azure.com/agentpool" = "applications"
        }

        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:${var.image_tag}"

          args = [
            "tunnel",
            "--no-autoupdate",
            "--metrics", "0.0.0.0:2000",
            "run",
          ]

          env {
            name = "TUNNEL_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.tunnel_token.metadata[0].name
                key  = "token"
              }
            }
          }

          # /ready returns 200 only once at least one connection to the
          # Cloudflare edge is up.
          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            failure_threshold     = 3
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          security_context {
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }
}
