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

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "purge_protection_enabled" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs allowed through the network ACL"
}

variable "vnet_id" {
  type = string
}

variable "ip_rules" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}
