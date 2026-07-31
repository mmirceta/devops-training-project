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
  default   = null
}

variable "admin_ssh_public_key" {
  type        = string
  default     = null
  description = "SSH public key for admin_username. When set, password authentication is disabled and admin_password is ignored."
}

variable "tags" {
  type = map(string)
}

variable "custom_data" {
  type        = string
  default     = null
  description = "Base64-encoded cloud-init. Defaults to the module's built-in cloud-init.yaml (Docker/Node/OpenTofu/Terragrunt tooling for a GitHub Actions runner)."
}
