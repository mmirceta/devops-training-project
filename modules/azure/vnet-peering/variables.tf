variable "name" {
  type        = string
  description = "Name of this peering resource (local side)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group of the local VNet"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the local VNet the peering is created on"
}

variable "remote_virtual_network_id" {
  type        = string
  description = "Resource ID of the remote VNet to peer with"
}

variable "allow_virtual_network_access" {
  type    = bool
  default = true
}

variable "allow_forwarded_traffic" {
  type    = bool
  default = false
}

variable "allow_gateway_transit" {
  type    = bool
  default = false
}

variable "use_remote_gateways" {
  type    = bool
  default = false
}
