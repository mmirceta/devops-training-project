variable "resource_group_name" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "name" {
  type        = string
  description = "Short name used in resource naming, e.g. 'acr-test', 'sql-test'"
}

variable "subnet_id" {
  type = string
}

variable "size" {
  type    = string
  default = "Standard_B1s"
}

variable "zone" {
  type    = string
  default = null
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}
