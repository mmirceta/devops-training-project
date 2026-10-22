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

variable "cloudflare_tunnel_token" {
  description = "Token of the remotely-managed tunnel, from the Cloudflare Zero Trust dashboard. Set via TF_VAR_cloudflare_tunnel_token (GitHub secret) or the root terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "namespace" {
  type    = string
  default = "cloudflared"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "image_tag" {
  type    = string
  default = "2026.10.0"
}

variable "cpu_request" {
  type    = string
  default = "10m"
}

variable "memory_request" {
  type    = string
  default = "32Mi"
}

variable "cpu_limit" {
  type    = string
  default = "200m"
}

variable "memory_limit" {
  type    = string
  default = "128Mi"
}
