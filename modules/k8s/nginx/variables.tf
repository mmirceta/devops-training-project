variable "host" {
  type      = string
  sensitive = true
}

variable "client_certificate" {
  type      = string
  sensitive = true
}

variable "client_key" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "namespace" {
  type    = string
  default = "nginx"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "image" {
  type    = string
  default = "nginx:1.27"
}

variable "cpu_limit" {
  type    = string
  default = "250m"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}

variable "cpu_request" {
  type    = string
  default = "50m"
}

variable "memory_request" {
  type    = string
  default = "64Mi"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "target_cpu_utilization_percentage" {
  type    = number
  default = 70
}

variable "vault_address" {
  type    = string
  default = "http://vault.vault.svc.cluster.local:8200"
}

variable "vault_role" {
  type    = string
  default = "nginx-role"
}

variable "vault_secret_path" {
  type    = string
  default = "secret/data/nginx"
}
