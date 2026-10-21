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
  default = "2.8.0"
}

variable "gateway_api_version" {
  description = "Gateway API standard-channel CRD release. Keep in sync with the version pinned by chart_version."
  type        = string
  default     = "v1.6.3"
}

variable "gateway_class_name" {
  type    = string
  default = "nginx"
}

variable "gateway_name" {
  type    = string
  default = "gateway"
}

variable "load_balancer_ip" {
  description = "Static private IP for the Gateway's internal LoadBalancer, inside the AKS node subnet. Null lets Azure pick one."
  type        = string
  default     = null
}
