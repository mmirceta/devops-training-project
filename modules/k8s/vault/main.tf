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

resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "vault_config" {
  metadata {
    name      = "vault-config"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "vault.hcl" = <<-EOT
      ui = true
      disable_mlock = true

      listener "tcp" {
        address     = "0.0.0.0:8200"
        tls_disable = 1
      }

      storage "file" {
        path = "/vault/data"
      }

      api_addr = "http://vault.${var.namespace}.svc.cluster.local:8200"
    EOT
  }
}

resource "kubernetes_stateful_set" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    service_name = "vault"
    replicas     = 1

    selector {
      match_labels = {
        app = "vault"
      }
    }

    template {
      metadata {
        labels = {
          app = "vault"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        security_context {
          fs_group = 1000
        }

        container {
          name    = "vault"
          image   = var.vault_image
          command = ["/bin/vault"]
          args    = ["server", "-config=/vault/config/vault.hcl"]

          env {
            name  = "VAULT_ADDR"
            value = "http://127.0.0.1:8200"
          }

          port {
            name           = "http"
            container_port = 8200
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            run_as_group               = 1000
            run_as_user                = 100

            capabilities {
              drop = ["ALL"]
            }
          }

          liveness_probe {
            http_get {
              path = "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204"
              port = 8200
            }
            initial_delay_seconds = 15
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204"
              port = 8200
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          volume_mount {
            name       = "config"
            mount_path = "/vault/config"
          }

          volume_mount {
            name       = "vault-data"
            mount_path = "/vault/data"
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.vault_config.metadata[0].name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "vault-data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }

  # volumeClaimTemplates are immutable in Kubernetes once the StatefulSet
  # exists (kubectl can't update them either); the kubernetes provider's
  # metadata.namespace default otherwise produces a spurious forced
  # replacement on every plan (hashicorp/terraform-provider-kubernetes#1775).
  lifecycle {
    ignore_changes = [spec[0].volume_claim_template]
  }
}

resource "kubernetes_service" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    selector = {
      app = "vault"
    }

    port {
      name        = "http"
      port        = 8200
      target_port = 8200
    }

    type = "ClusterIP"
  }
}

# Lets Vault's Kubernetes auth method call the TokenReview API (using the
# server's own "default" SA token) to validate service account tokens
# presented by workloads like nginx-vault.
resource "kubernetes_cluster_role_binding" "vault_tokenreview" {
  metadata {
    name = "vault-tokenreview"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.6.0"

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "vault_csi_provider" {
  name       = "vault-csi-provider"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.34.1"

  set {
    name  = "csi.enabled"
    value = "true"
  }

  set {
    name  = "injector.enabled"
    value = "false"
  }

  set {
    name  = "server.enabled"
    value = "false"
  }

  set {
    name  = "global.externalVaultAddr"
    value = "http://vault.${var.namespace}.svc.cluster.local:8200"
  }

  depends_on = [helm_release.csi_secrets_store, kubernetes_service.vault]
}
