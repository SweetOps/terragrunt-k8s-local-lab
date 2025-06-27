locals {
  inputs = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
    static_dependencies = ["prometheus-operator-crds", "cert-manager"]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
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

dependencies {
  paths = formatlist(
    "${get_path_to_repo_root()}/addons/argocd/%s",
    local.static_dependencies
  )
}

inputs = try(local.inputs.locals.argocd.cassandra_operator.inputs, {})

exclude {
  if      = feature.initial_apply.value || !try(local.inputs.locals.argocd.cassandra_operator.enabled, true)
  actions = ["all"]
}
