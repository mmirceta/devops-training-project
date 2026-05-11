include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/azure/rg/"
}

inputs = {
  environment = "dev"

  tags = {
    environment = "dev"
    project     = "devops-training"
  }
}