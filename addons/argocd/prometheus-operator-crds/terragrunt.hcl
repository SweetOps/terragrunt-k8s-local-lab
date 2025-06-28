locals {
  inputs  = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  exclude = feature.initial_apply.value || !try(local.inputs.locals.argocd.prometheus_operator_crds.enabled, true)
}

dependency "k8s" {
  config_path = "${get_path_to_repo_root()}/k8s"
  mock_outputs = {
    endpoint               = "https://test.k8s.dev"
    client_key             = "test_client_key"
    client_certificate     = "test_client_certificate"
    cluster_ca_certificate = "test_cluster_ca_certificate"
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = try(local.inputs.locals.argocd.prometheus_operator_crds.inputs, {})

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
