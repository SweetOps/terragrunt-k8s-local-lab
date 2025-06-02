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
  }
}

dependency "prometheus_operator_crds" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/prometheus-operator-crds"
  skip_outputs = true
}

dependency "ingress_nginx" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/ingress-nginx"
  skip_outputs = true
}

dependency "argocd" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/argocd"
  skip_outputs = true
}

dependency "local_path_provisioner" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/local-path-provisioner"
  skip_outputs = true
}

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

inputs = merge(
  {
    cluster_issuer_name = dependency.cert_manager.outputs.cluster_issuer_name
  },
  try(local.inputs.locals.argocd.vault.inputs, {})
)

exclude {
  if      = feature.initial_apply.value || !try(local.inputs.locals.argocd.vault.enabled, true)
  actions = ["all"]
}
