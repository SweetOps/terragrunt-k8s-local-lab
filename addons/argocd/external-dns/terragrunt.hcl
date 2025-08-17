locals {
  inputs  = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  exclude = feature.initial_apply.value || !try(local.inputs.locals.argocd.external_dns.enabled, true)
  values = {
    provider = {
      name = "coredns"
      coredns = {
        endpoints = [
          "http://${dependency.coredns.etcd_ip_address}:2379"
        ]
        zone = local.inputs.locals.domain
      }
    }
    domainFilters = [
      local.inputs.locals.domain
    ]
    registry   = "txt"
    txtOwnerId = dependency.k8s.outputs.cluster_name
  }
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

dependency "coredns" {
  config_path = "${get_path_to_repo_root()}/k8s/coredns"
  mock_outputs = {
    etcd_ip_address    = "10.0.0.0"
    coredns_ip_address = "10.0.0.1"
  }
}

dependency "prometheus_operator_crds" {
  config_path  = "${get_path_to_repo_root()}/addons/argocd/prometheus-operator-crds"
  skip_outputs = true
}

inputs = merge(
  {
    inherited_values = yamlencode(local.values)
  },
  try(local.inputs.locals.argocd.vm_stack.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
