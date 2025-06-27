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

generate "k8s_provider" {
  path      = "tg-k8s-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "kubernetes" {
    host                   = "${dependency.k8s.outputs.endpoint}"
    client_key             = <<-KEY
${dependency.k8s.outputs.client_key}
KEY
    client_certificate     = <<-CERT
${dependency.k8s.outputs.client_certificate}"
CERT
    cluster_ca_certificate = <<-CA
${dependency.k8s.outputs.cluster_ca_certificate}
CA
}
EOF
}

dependency "cilium" {
  config_path  = "${get_path_to_repo_root()}/addons/helm/cilium"
  skip_outputs = true
}

dependency "cilium_lb" {
  config_path  = "${get_path_to_repo_root()}/addons/helm/cilium-lb"
  skip_outputs = true
}

inputs = try(local.inputs.locals.helm.argocd.inputs, {})

exclude {
  if      = !feature.initial_apply.value || !try(local.inputs.locals.helm.argocd.enabled, true)
  actions = ["all"]
}
