locals {
  inputs = try(read_terragrunt_config(find_in_parent_folders("globals.hcl")), {})
}

inputs = local.inputs.locals.k8s
