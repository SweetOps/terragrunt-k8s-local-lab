locals {
  inputs  = try(read_terragrunt_config(find_in_parent_folders("globals.hcl")), {})
  exclude = !feature.initial_apply.value || !try(local.inputs.locals.k8s.registry.enabled, true)
}

dependency "k8s" {
  config_path  = "${get_path_to_repo_root()}/k8s/cluster"
  skip_outputs = true
}

inputs = try(local.inputs.locals.k8s.registry.inputs, {})

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
