variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "container_name" {
  type = string
}

variable "tags" {
  type = map(string)
}