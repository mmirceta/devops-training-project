locals {
  env = "prod"
}

inputs = {
  env = local.env

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}