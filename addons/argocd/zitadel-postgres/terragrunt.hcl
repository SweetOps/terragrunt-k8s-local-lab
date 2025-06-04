locals {
  inputs = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
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
    cluster_name           = "test"
  }
}

dependency "prometheus_operator_crds" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/prometheus-operator-crds"
  skip_outputs = true
}

dependency "postgres_operator" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/postgres-operator"
  skip_outputs = true
}

inputs = try(local.inputs.locals.argocd.zitadel_postgres.inputs, {})

exclude {
  if      = feature.initial_apply.value || !try(local.inputs.locals.argocd.zitadel_postgres.enabled, true) || !try(local.inputs.locals.argocd.zitadel.enabled, true)
  actions = ["all"]
}
