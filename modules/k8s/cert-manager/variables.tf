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

variable "chart_version" {
  type    = string
  default = "v1.21.2"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:DNS:Edit on the zones certificates are issued for. Set via TF_VAR_cloudflare_api_token (GitHub secret) or the root terraform.tfvars."
  type        = string
  sensitive   = true
}
