locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "cert-manager"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.clickhouse_operator.enabled, true)
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
  }
}

dependency "external_secrets" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/external-secrets"
  mock_outputs = {
    vault_mount_path          = "test"
    cluster_secret_store_name = "test"
  }
}

dependency "vault" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/vault"
  mock_outputs = {
    url   = "https://test.vault.dev"
    token = "test"
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
    cluster_secret_store_name = dependency.external_secrets.outputs.cluster_secret_store_name
    vault_mount_path          = dependency.external_secrets.outputs.vault_mount_path
  },
  try(local.inputs.locals.argocd.clickhouse_operator.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
