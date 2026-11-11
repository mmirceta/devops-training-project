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
  description = "flux2 chart version (fluxcd-community). 2.19.1 ships Flux v2.9.5."
  type        = string
  default     = "2.19.1"
}

variable "sync_chart_version" {
  description = "flux2-sync chart version, matching chart_version's Flux release."
  type        = string
  default     = "1.15.1"
}

variable "git_url" {
  description = "HTTPS URL of the GitOps repo. Must be public: no credentials Secret is configured."
  type        = string
}

variable "git_branch" {
  type    = string
  default = "main"
}

variable "git_path" {
  description = "Folder in the GitOps repo this cluster applies, e.g. ./dev."
  type        = string
}
