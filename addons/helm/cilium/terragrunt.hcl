locals {
  inputs  = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  exclude = !feature.initial_apply.value || !try(local.inputs.locals.helm.cilium.enabled, true)
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
    pod_subnet             = "10.244.0.0/16"
    service_subnet         = "10.96.0.0/12"
    api_server_port        = 6443
    cluster_name           = "test"
  }
}

inputs = merge(
  {
    k8s_api_server_port = dependency.k8s.outputs.api_server_port
    k8s_pod_subnet      = dependency.k8s.outputs.pod_subnet
    k8s_cluster_name    = dependency.k8s.outputs.cluster_name
  },
  try(local.inputs.locals.helm.cilium.inputs, {}),
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
