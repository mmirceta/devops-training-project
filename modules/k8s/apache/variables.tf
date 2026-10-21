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
  default = "apache"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "image" {
  type    = string
  default = "httpd:2.4"
}

variable "cpu_limit" {
  type    = string
  default = "250m"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}

variable "gateway_route_enabled" {
  description = "Create an HTTPRoute on the shared NGINX Gateway Fabric Gateway. Requires the Gateway API CRDs to be installed first."
  type        = bool
  default     = false
}

variable "gateway_name" {
  type    = string
  default = "gateway"
}

variable "gateway_namespace" {
  type    = string
  default = "nginx-gateway"
}
