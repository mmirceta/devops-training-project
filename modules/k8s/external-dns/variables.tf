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
  default = "1.23.0"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:Zone:Read and Zone:DNS:Edit on the managed zones. Set via TF_VAR_cloudflare_api_token (GitHub secret) or the root terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "domain_filters" {
  description = "Zones external-dns may manage records in."
  type        = list(string)
}

variable "txt_owner_id" {
  description = "Owner ID written to the TXT ownership records. external-dns only changes or deletes records carrying its own ID."
  type        = string
}

variable "policy" {
  description = "sync also deletes records whose source is gone; upsert-only never deletes."
  type        = string
  default     = "sync"
}
