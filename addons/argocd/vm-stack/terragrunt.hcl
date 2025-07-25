locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "ingress-nginx", "vm-operator"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.vm_stack.enabled, true)
  domain              = local.inputs.locals.domain
  cluster_issuer_name = local.inputs.locals.cluster_issuer_name

  hostnames = {
    grafana      = format("grafana.%s", local.domain)
    vmsingle     = format("vm-single.%s", local.domain)
    alertmanager = format("alertmanager.%s", local.domain)
  }

  ingresses = { for k, v in local.hostnames : k => {
    enabled          = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
    ingressClassName = "nginx"
    annotations = {
      "cert-manager.io/cluster-issuer" = local.cluster_issuer_name
    }
    hosts = [v]
    tls = [
      {
        secretName = v
        hosts      = [v]
      }
    ]
    }
  }

  ingress = {
    enabled          = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
    ingressClassName = "nginx"
    annotations = {
      "cert-manager.io/cluster-issuer" = local.cluster_issuer_name
    }
  }

  values = {
    victoria-metrics-operator = {
      enabled = !try(local.inputs.locals.argocd.vm_operator.enabled, true)
    }

    vmsingle = {
      ingress = local.ingresses.vmsingle
    }

    alertmanager = {
      ingress = local.ingresses.alertmanager
    }

    grafana = {
      ingress = local.ingresses.grafana
    }
  }
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

dependencies {
  paths = formatlist(
    "${get_path_to_repo_root()}/addons/argocd/%s",
    local.static_dependencies
  )
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

dependency "cert_manager" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/cert-manager"
  mock_outputs = {
    cluster_issuer_name = "test"
  }
}

inputs = merge(
  {
    k8s_cluster_name          = dependency.k8s.outputs.cluster_name
    cluster_issuer_name       = dependency.cert_manager.outputs.cluster_issuer_name
    cluster_secret_store_name = dependency.external_secrets.outputs.cluster_secret_store_name
    vault_mount_path          = dependency.external_secrets.outputs.vault_mount_path
    inherited_values          = yamlencode(local.values)
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
