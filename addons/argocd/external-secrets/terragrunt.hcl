locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds"]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vault_provider" {
  path = find_in_parent_folders("vault-provider.hcl")
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

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

dependency "vault" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/vault"
  mock_outputs = {
    token        = "test_vault_token"
    url          = "https://test.vault.dev"
    internal_url = "http://test.vault.dev:8200"
  }
}

dependencies {
  paths = formatlist(
    "${get_path_to_repo_root()}/addons/argocd/%s",
    local.static_dependencies
  )
}

inputs = (
  merge(
    {
      cluster_issuer_name = dependency.cert_manager.outputs.cluster_issuer_name
      k8s_cluster_name    = dependency.k8s.outputs.cluster_name
      vault_url           = dependency.vault.outputs.internal_url
      vault_token         = dependency.vault.outputs.token
    },
    try(local.inputs.locals.argocd.external_secrets.inputs, {})
  )
)

exclude {
  if      = feature.initial_apply.value || !try(local.inputs.locals.argocd.external_secrets.enabled, true) && !try(local.inputs.locals.argocd.vault.enabled, true)
  actions = ["all"]
}
