locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds"]
  exclude             = feature.initial_apply.value
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

dependency "registry" {
  config_path = "${get_path_to_repo_root()}/k8s/registry"
  mock_outputs = {
    host_url = "https://test.k8s.dev"
    url = "https://test.k8s.dev"
    host_endpoint = "test.k8s.dev:50000"
    endpoint = "test.k8s.dev:443"
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
    k8s_api_server_port = dependency.k8s.outputs.api_server_port
    k8s_pod_subnet      = dependency.k8s.outputs.pod_subnet
    k8s_cluster_name    = dependency.k8s.outputs.cluster_name
    registry_endpoints  = {
      host = dependency.registry.outputs.host_endpoint
      in_cluster = dependency.registry.outputs.endpoint
    }
  },
  try(local.inputs.locals.argocd.cilium.inputs, {})
)

feature "initial_apply" {
  default = false
}

feature "cilium_skip_destroy" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
