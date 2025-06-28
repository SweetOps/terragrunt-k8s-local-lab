locals {
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

resource "random_password" "main" {
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
      "${local.master_key_secret_key}" = random_password.main.result
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
    var.inherited_values,
    var.override_values,
  ]
}
