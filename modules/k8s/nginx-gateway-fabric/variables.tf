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

variable "load_balancer_internal" {
  description = "true: internal LoadBalancer in the AKS node subnet. false: public LoadBalancer (see public_ip_name)."
  type        = bool
  default     = true
}

variable "load_balancer_ip" {
  description = "Static private IP for the Gateway's internal LoadBalancer, inside the AKS node subnet. Only used when load_balancer_internal is true. Null lets Azure pick one."
  type        = string
  default     = null
}

variable "public_ip_name" {
  description = "Name of a pre-created static public IP for the Gateway's public LoadBalancer. Only used when load_balancer_internal is false. Null lets AKS create a dynamic one in the node resource group."
  type        = string
  default     = null
}

variable "public_ip_resource_group" {
  description = "Resource group of public_ip_name, when it lives outside the MC_* node resource group. The AKS identity needs Network Contributor on the IP."
  type        = string
  default     = null
}
