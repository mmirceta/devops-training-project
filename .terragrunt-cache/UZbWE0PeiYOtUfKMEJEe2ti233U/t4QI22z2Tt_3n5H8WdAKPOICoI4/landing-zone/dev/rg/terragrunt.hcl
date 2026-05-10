include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/azure/rg"
}

inputs = {
  environment = "dev"

  tags = {
    environment = "dev"
    project     = "devops-training"
  }
}