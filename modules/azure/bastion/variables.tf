variable "resource_group_name" {
  type = string
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "subnet_id" {
  type        = string
  description = "ID of the AzureBastionSubnet subnet"
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "scale_units" {
  type    = number
  default = 2
}

variable "tags" {
  type = map(string)
}
