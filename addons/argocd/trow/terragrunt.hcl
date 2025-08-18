locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "ingress-nginx", "local-path-provisioner"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.trow.enabled, true)
  hostname            = format("trow.%s", local.inputs.locals.domain)
  cluster_issuer_name = local.inputs.locals.cluster_issuer_name

  values = {
    trow = {
      domain = local.hostname
    }
    ingress = {
      enabled = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
      annotations = {
        "cert-manager.io/cluster-issuer"              = local.cluster_issuer_name
        "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
      }
      ingressClassName = "nginx"
      hosts = [
        {
          host  = local.hostname
          paths = ["/"]
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
  try(local.inputs.locals.argocd.trow.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
