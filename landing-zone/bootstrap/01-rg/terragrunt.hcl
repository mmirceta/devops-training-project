include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rg/"
}

locals {
  env = "bootstrap"
}

inputs = {
  env = local.env

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}