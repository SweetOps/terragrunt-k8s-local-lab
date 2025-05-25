locals {
  api_hostname     = "minio-api.${var.domain}"
  console_hostname = "minio.${var.domain}"
  secret_name      = "s3-env-configuration"

  ingress = {
    enabled = true
    annotations = {
      "cert-manager.io/cluster-issuer"                 = var.cluster_issuer_name
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
      "nginx.ingress.kubernetes.io/proxy-ssl-verify"   = "off"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "60s"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "60s"
    }
    ingressClassName = "nginx"
  }

  values = {
    fullNameOverride = "minio-tenant"
    tenant = {
      name = "s3"
      configSecret = {
        name           = local.secret_name
        existingSecret = true
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
        }
      ]
      features = {
        domains = {
          minio   = ["minio.${var.destination.namespace}.svc.cluster.local", local.api_hostname]
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
    var.override_values,
  ]
}
