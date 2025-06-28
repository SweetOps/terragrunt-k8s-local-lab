locals {
  inputs                = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  static_dependencies   = ["prometheus-operator-crds", "ingress-nginx"]
  exclude               = feature.initial_apply.value || !try(local.inputs.locals.argocd.zitadel.enabled, true)
  domain                = local.inputs.locals.domain
  cluster_issuer_name   = local.inputs.locals.cluster_issuer_name
  hostname              = format("zitadel.%s", local.domain)
  postgres_cluster_name = "zitadel-postgres"

  values = {
    ingress = {
      enabled   = try(local.inputs.locals.argocd.ingress_nginx.enabled, true)
      className = "nginx"
      annotations = {
        "cert-manager.io/cluster-issuer" = local.cluster_issuer_name
      }
      hosts = [
        {
          host = local.hostname
          paths = [
            {
              path     = "/"
              pathType = "Prefix"
            }
          ]
        }
      ]
      tls = [
        {
          secretName = local.hostname
          hosts      = [local.hostname]
        }
      ]
    }
    env = [
      {
        name  = "ZITADEL_EXTERNALDOMAIN"
        value = local.hostname
      },
      {
        name  = "ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE"
        value = "disable"
      },
      {
        name  = "ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE"
        value = "disable"
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_HOST"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-app"
            key  = "host"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_PORT"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-app"
            key  = "port"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_DATABASE"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-app"
            key  = "dbname"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_USER_USERNAME"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-app"
            key  = "username"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_USER_PASSWORD"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-app"
            key  = "password"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-superuser"
            key  = "username"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD"
        valueFrom = {
          secretKeyRef = {
            name = "${local.postgres_cluster_name}-cluster-superuser"
            key  = "password"
          }
        }
      }
    ]
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

dependency "zitadel_postgres" {
  config_path = "${get_path_to_repo_root()}/addons/argocd/${local.postgres_cluster_name}"
  mock_outputs = {
    cluster_name = "test"
  }
}

inputs = merge(
  {
    k8s_cluster_name          = dependency.k8s.outputs.cluster_name
    cluster_secret_store_name = dependency.external_secrets.outputs.cluster_secret_store_name
    vault_mount_path          = dependency.external_secrets.outputs.vault_mount_path
    inherited_values          = yamlencode(local.values)
  },
  try(local.inputs.locals.argocd.zitadel.inputs, {})
)

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
