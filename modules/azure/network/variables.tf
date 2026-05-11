variable "resource_group_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
  }))
}

##### by this point, it was without ai: 
variable "nsgs" {
  type = map(object({
    name = string
    rules = map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "tags" {
  type = map(string)
}