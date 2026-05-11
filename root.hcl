remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "terraform.tfstate"
  }
}

# remote_state {
#   backend = "azurerm"

#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   } 

#   config = {
#     resource_group_name  = "rg-dev-training"
#     storage_account_name = "satfstatedevmm"
#     container_name       = "tfstatedev"
#     key                  = "${path_relative_to_include()}/tofu.tfstate"
#   }
# }

inputs = {
  location = "north europe"
}


# [ ] transfer state: tg init -migrate-state
# [ ] transfer provider block here and remove from modules

