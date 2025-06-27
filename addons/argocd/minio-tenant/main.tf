locals {
  secret_name = "s3-env-configuration"

  values = {
    fullNameOverride = "minio-tenant"
    tenant = {
      name = "s3"
      configSecret = {
        name           = local.secret_name
        existingSecret = true
      }

      features = {
        bucketDNS = true
      }

      pools = [
        {
          name             = "s3"
          servers          = 1
          volumesPerServer = 1
        }
      ]

      metrics = {
        enabled = true
      }

      buckets = [
        {
          name = "postgres"
        },
        {
          name = "kafka"
        },
        {
          name = "temporal"
        },
        {
          name = "clickhouse"
        }
      ]
    }
    extraResources = [
      {
        apiVersion = "external-secrets.io/v1"
        kind       = "ExternalSecret"
        metadata = {
          name      = local.secret_name
          namespace = var.destination.namespace
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
            name           = local.secret_name
            creationPolicy = "Owner"
            template = {
              type = "Opaque"
              data = {
                "config.env" = "\nexport MINIO_ROOT_USER={{ \"{{ .access_key }}\" }}\nexport MINIO_ROOT_PASSWORD={{ \"{{ .secret_key }}\" }}"
              }
            }
          }
          dataFrom = [
            {
              extract = {
                key = vault_kv_secret_v2.main.name
              }
            }
          ]
        }
      }
    ]
  }
}

resource "random_string" "main" {
  for_each = toset(["access_key", "secret_key"])
  length   = 16
  upper    = true
  lower    = true
  special  = false
}

resource "vault_kv_secret_v2" "main" {
  mount = var.vault_mount_path
  name  = format("%s/%s/%s", var.destination.namespace, var.chart, local.secret_name)

  data_json = jsonencode(
    {
      access_key = random_string.main["access_key"].result
      secret_key = random_string.main["secret_key"].result
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
