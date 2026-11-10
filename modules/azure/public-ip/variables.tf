variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "domain_name_label" {
  description = "DNS label, giving the IP the name <label>.<region>.cloudapp.azure.com. Must be unique within the region."
  type        = string
  default     = null
}

variable "aks_identity_name" {
  description = "User-assigned identity of an AKS cluster (in the same resource group) that gets Network Contributor on this IP, so its LoadBalancer can use it. Null skips the role assignment."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
