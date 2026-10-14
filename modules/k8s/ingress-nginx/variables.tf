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
  default = "4.11.3"
}

variable "load_balancer_ip" {
  description = "Static private IP for the controller's internal LoadBalancer, inside the AKS node subnet. Null lets Azure pick one."
  type        = string
  default     = null
}
