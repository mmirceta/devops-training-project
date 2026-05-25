include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/rg/"
}


