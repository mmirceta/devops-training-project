# remote_state {
#   backend = "local"
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   }
#   config = {
#     path = "terraform.tfstate"
#   }
# }

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    resource_group_name  = "rg-devops-training-bootstrap"
    storage_account_name = "sabootstraptrainingmm"
    container_name       = "tfstate-${local.env}"
    key                  = "${path_relative_to_include()}/tofu.tfstate"
  }
}

locals {
  path_parts = split("/", path_relative_to_include())
  env        = local.path_parts[length(local.path_parts) - 2]
}

inputs = {
  location = "west europe"
}

