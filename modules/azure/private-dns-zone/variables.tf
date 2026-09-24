variable "name" {
  type        = string
  description = "Private DNS zone name, e.g. privatelink.westeurope.azmk8s.io"
}

variable "resource_group_name" {
  type = string
}

variable "vnet_ids" {
  type        = map(string)
  description = "Map of link-name => VNet ID to link this zone to"
}

variable "tags" {
  type    = map(string)
  default = {}
}
