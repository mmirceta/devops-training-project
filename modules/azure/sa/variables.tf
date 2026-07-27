variable "resource_group_name" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "ip_rules" {
  type    = list(string)
  default = []
}

variable "containers" {
  type    = list(string)
  default = []
}

variable "enable_lock" {
  type    = bool
  default = false
}