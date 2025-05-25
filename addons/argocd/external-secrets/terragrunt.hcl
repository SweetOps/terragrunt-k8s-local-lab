locals {
  inputs = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
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

dependency "prometheus_operator_crds" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/prometheus-operator-crds"
  skip_outputs = true
}

dependency "cert_manager" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  skip_outputs = true
}

dependency "vault" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/vault"
  mock_outputs = {
    token        = "test_vault_token"
    url          = "https://test.vault.dev"
    internal_url = "http://test.vault.dev:8200"
  }
}

inputs = (
  merge(
    {
      k8s_cluster_name = dependency.k8s.outputs.cluster_name
      vault_url        = dependency.vault.outputs.internal_url
      vault_token      = dependency.vault.outputs.token
    },
    try(local.inputs.locals.argocd.external_secrets, {})
  )
)
