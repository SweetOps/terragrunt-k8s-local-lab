locals {
  hostname               = "zitadel.${var.domain}"
  master_key_secret_name = "zitadel-masterkey"
  master_key_secret_key  = "masterkey"

  values = {
    replicaCount = 1
    zitadel = {
      masterkeySecretName = local.master_key_secret_name
      configmapConfig = {
        TLS = {
          Enabled = false
        }
      }
    }

    ingress = {
      enabled   = true
      className = "nginx"
      annotations = {
        "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
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
            name = "${var.postgres_cluster_name}-cluster-app"
            key  = "host"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_PORT"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-app"
            key  = "port"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_DATABASE"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-app"
            key  = "dbname"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_USER_USERNAME"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-app"
            key  = "username"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_USER_PASSWORD"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-app"
            key  = "password"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-superuser"
            key  = "username"
          }
        }
      },
      {
        name = "ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD"
        valueFrom = {
          secretKeyRef = {
            name = "${var.postgres_cluster_name}-cluster-superuser"
            key  = "password"
          }
        }
      }
    ]

    initJob = {
      annotations = {
        "argocd.argoproj.io/hook"      = "Sync"
        "argocd.argoproj.io/sync-wave" = "-4"
      }
    }

    setupJob = {
      annotations = {
        "argocd.argoproj.io/hook"      = "Sync"
        "argocd.argoproj.io/sync-wave" = "-4"
      }
    }

    metrics = {
      enabled = true
      serviceMonitor = {
        enabled = true
      }
    }

    extraManifests = [
      {
        apiVersion = "external-secrets.io/v1"
        kind       = "ExternalSecret"
        metadata = {
          name = local.master_key_secret_name
          annotations = {
            "argocd.argoproj.io/sync-wave" = "-5"
          }
        }
        spec = {
          refreshInterval = "10m"
          secretStoreRef = {
            name = var.cluster_secret_store_name
            kind = "ClusterSecretStore"
          }

          target = {
            name           = local.master_key_secret_name
            creationPolicy = "Owner"
          }
          dataFrom = [
            {
              extract = {
                conversionStrategy = "Default"
                decodingStrategy   = "None"
                metadataPolicy     = "None"
                key                = vault_kv_secret_v2.main.name
              }
            }
          ]
        }
      }
    ]
  }
}

resource "random_string" "main" {
  length  = 32
  upper   = true
  lower   = true
  special = false
}

resource "vault_kv_secret_v2" "main" {
  mount = var.vault_mount_path
  name  = format("%s/%s/%s", var.destination.namespace, var.chart, local.master_key_secret_name)

  data_json = jsonencode(
    {
      "${local.master_key_secret_key}" = random_string.main.result
    }
  )
}

module "argocd" {
  source = "../../../modules/argocd"

  chart         = var.chart
  repository    = var.repository
  chart_version = var.chart_version
  metadata      = var.metadata
  destination   = var.destination
  wait          = var.wait
  sync_policy   = var.sync_policy
  sync_options  = var.sync_options
  retry         = var.retry
  values        = data.utils_deep_merge_yaml.main.output
}

data "utils_deep_merge_yaml" "main" {
  input = [
    yamlencode(local.values),
    var.override_values,
  ]
}
