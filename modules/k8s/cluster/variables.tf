variable "resource_group_name" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the AKS node pools"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Custom private DNS zone ID for the AKS API server. Requires the cluster identity to have Private DNS Zone Contributor on it."
}

variable "system_node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "system_node_count" {
  type    = number
  default = 1
}

variable "applications_node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "applications_node_count" {
  type    = number
  default = 1
}

variable "tags" {
  type = map(string)
}
