variable "resource_group_name" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
