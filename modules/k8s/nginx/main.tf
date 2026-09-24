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

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "nginx_vault" {
  metadata {
    name      = "nginx-vault"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  automount_service_account_token = false
}

# Requires the secrets-store.csi.x-k8s.io CRDs and the Vault CSI provider
# to already be installed on the cluster (see modules/k8s/vault).
resource "kubernetes_manifest" "nginx_vault_secrets" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"

    metadata = {
      name      = "nginx-vault-secrets"
      namespace = kubernetes_namespace.nginx.metadata[0].name
    }

    spec = {
      provider = "vault"

      parameters = {
        vaultAddress = var.vault_address
        roleName     = var.vault_role
        audience     = "vault"

        objects = <<-EOT
          - objectName: "username"
            secretPath: "${var.vault_secret_path}"
            secretKey: "username"

          - objectName: "password"
            secretPath: "${var.vault_secret_path}"
            secretKey: "password"
        EOT
      }
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        node_selector = {
          "kubernetes.azure.com/agentpool" = "applications"
        }

        service_account_name = kubernetes_service_account.nginx_vault.metadata[0].name

        init_container {
          name  = "verify-vault-secrets"
          image = "busybox:1.36"

          command = [
            "/bin/sh",
            "-ec",
            "test -s /mnt/secrets-store/username; test -s /mnt/secrets-store/password; test \"$(cat /mnt/secrets-store/username)\" != \"null\"; test \"$(cat /mnt/secrets-store/password)\" != \"null\"; echo \"Vault secrets successfully validated\""
          ]

          volume_mount {
            name       = "vault-secrets"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }
        }

        container {
          name              = "nginx"
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

          volume_mount {
            name       = "vault-secrets"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }
        }

        volume {
          name = "vault-secrets"

          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true

            volume_attributes = {
              secretProviderClass = kubernetes_manifest.nginx_vault_secrets.manifest.metadata.name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
