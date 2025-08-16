locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "ingress-nginx"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.argocd.enabled, true) || feature.argocd_skip_destroy.value
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s" {
  config_path = "${get_path_to_repo_root()}/k8s/cluster"
  mock_outputs = {
    endpoint               = "https://test.k8s.dev"
    client_key             = "test_client_key"
    client_certificate     = "test_client_certificate"
    cluster_ca_certificate = "test_cluster_ca_certificate"
    pod_subnet             = "10.244.0.0/16"
    service_subnet         = "10.96.0.0/12"
    api_server_port        = 6443
    cluster_name           = "test"
  }
}

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

dependencies {
  paths = formatlist(
    "${get_path_to_repo_root()}/addons/argocd/%s",
    local.static_dependencies
  )
}

inputs = merge(
  {
    cluster_issuer_name = dependency.cert_manager.outputs.cluster_issuer_name
  },
  try(local.inputs.locals.argocd.argocd.inputs, {})
)

feature "initial_apply" {
  default = false
}

feature "argocd_skip_destroy" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
