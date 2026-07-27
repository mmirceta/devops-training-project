include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "prod" {
  path = find_in_parent_folders("prod.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/azure/rg/"
}


