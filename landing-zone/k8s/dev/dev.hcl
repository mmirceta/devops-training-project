locals {
  env = "dev"
}

inputs = {
  env = local.env

  tags = {
    environment = local.env
    project     = "devops-training"
  }
}
