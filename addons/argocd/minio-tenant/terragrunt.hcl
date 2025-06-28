locals {
  inputs              = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies = ["prometheus-operator-crds", "ingress-nginx", "minio-operator"]
  exclude             = feature.initial_apply.value || !try(local.inputs.locals.argocd.minio_tenant.enabled, true)
  domain              = local.inputs.locals.domain
  cluster_issuer_name = local.inputs.locals.cluster_issuer_name
  api_hostname        = format("minio-api.%s", local.domain)
  console_hostname    = format("minio.%s", local.domain)

  ingress = {
    enabled = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
    annotations = {
      "cert-manager.io/cluster-issuer"                 = local.cluster_issuer_name
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
      "nginx.ingress.kubernetes.io/proxy-ssl-verify"   = "off"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "60"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "60"
    }
    ingressClassName = "nginx"
  }

  values = {
    tenant = {
      features = {
        domains = {
          minio   = [local.api_hostname]
          console = local.console_hostname
        }
      }
    }
    ingress = {
      api = merge(
        {
          host = local.api_hostname
          tls = [
            {
              secretName = local.api_hostname
              hosts      = [local.api_hostname]
            }
          ]
        },
        local.ingress
      )
      console = merge(
        {
          host = local.console_hostname
          tls = [
            {
              secretName = local.console_hostname
              hosts      = [local.console_hostname]
            }
          ]
        },
        local.ingress
      )
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
    cluster_secret_store_name = dependency.external_secrets.outputs.cluster_secret_store_name
    vault_mount_path          = dependency.external_secrets.outputs.vault_mount_path
    inherited_values          = yamlencode(local.values)
  },
  try(local.inputs.locals.argocd.minio_tenant.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
