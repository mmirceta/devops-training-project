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
  description = "argo-cd chart version (argoproj/argo-helm). 10.17.2 ships Argo CD v3.6.1."
  type        = string
  default     = "10.17.2"
}

variable "apps_chart_version" {
  description = "argocd-apps chart version, renders the root Application."
  type        = string
  default     = "2.0.8"
}

variable "hostname" {
  description = "Public hostname of the Argo CD UI, served through the shared Gateway's HTTPS listener."
  type        = string
}

variable "git_url" {
  description = "HTTPS URL of the GitOps repo. Must be public: no repository credentials are configured."
  type        = string
}

variable "git_branch" {
  type    = string
  default = "main"
}

variable "git_path" {
  description = "Folder in the GitOps repo the root Application syncs (recursively), e.g. dev."
  type        = string
}
