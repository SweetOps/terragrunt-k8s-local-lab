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

dependency "ingress_nginx" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/ingress-nginx"
  skip_outputs = true
}

dependency "external_secrets" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/external-secrets"
  skip_outputs = true
}

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

dependency "vm_operator" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/vm-operator"
  skip_outputs = true
}

dependency "vm-stack" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/vm-stack"
  skip_outputs = true
}

inputs = merge(
  {
    cluster_issuer_name = dependency.cert_manager.outputs.cluster_issuer_name
  },
  try(local.inputs.locals.argocd.vm_logs.inputs, {})
)

exclude {
  if      = feature.initial_apply.value || !try(local.inputs.locals.argocd.vm_logs.enabled, true)
  actions = ["all"]
}
