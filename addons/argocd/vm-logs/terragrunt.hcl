locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "ingress-nginx", "external-secrets"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.vm_logs.enabled, true)
  domain              = local.inputs.locals.domain
  cluster_issuer_name = local.inputs.locals.cluster_issuer_name
  hostname            = format("vm-logs.%s", local.domain)

  values = {
    server = {
      ingress = {
        enabled = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
        annotations = {
          "cert-manager.io/cluster-issuer" = local.cluster_issuer_name
        }
        ingressClassName = "nginx"
        hosts = [
          {
            name = local.hostname
            path = ["/"]
            port = "http"
          }
        ]
        tls = [
          {
            secretName = local.hostname
            hosts      = [local.hostname]
          }
        ]
      }
    }
  }
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

dependencies {
  paths = formatlist(
    "${get_path_to_repo_root()}/addons/argocd/%s",
    local.static_dependencies
  )
}

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

inputs = merge(
  {
    inherited_values = yamlencode(local.values)
  },
  try(local.inputs.locals.argocd.vm_logs.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
