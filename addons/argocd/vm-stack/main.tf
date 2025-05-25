locals {
  grafana_hostname      = "grafana.${var.domain}"
  vmsingle_hostname     = "vm-single.${var.domain}"
  alertmanager_hostname = "alertmanager.${var.domain}"
  secret_name           = "grafana-admin"

  ingress = {
    enabled          = true
    ingressClassName = "nginx"
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
    }
  }

  values = {
    victoria-metrics-operator = {
      enabled = false
    }

    vmsingle = {
      ingress = merge(
        local.ingress,
        {
          hosts = [local.vmsingle_hostname]
          tls = [
            {
              secretName = local.vmsingle_hostname
              hosts      = [local.vmsingle_hostname]
            }
          ]
        }
      )
    }

    alertmanager = {
      ingress = merge(
        local.ingress,
        {
          hosts = [local.alertmanager_hostname]
          tls = [
            {
              secretName = local.alertmanager_hostname
              hosts      = [local.alertmanager_hostname]
            }
          ]
        }
      )
    }

    grafana = {
      admin = {
        existingSecret = "grafana-admin"
        userKey        = "username"
        passwordKey    = "password"
      }

      serviceMonitor = {
        enabled = true
      }

      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        annotations = {
          "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
        }
        hosts = [local.grafana_hostname]
        tls = [
          {
            secretName = local.grafana_hostname
            hosts      = [local.grafana_hostname]
          }
        ]
      }
    }
    extraObjects = [
      {
        apiVersion = "external-secrets.io/v1"
        kind       = "ExternalSecret"
        metadata = {
          name = local.secret_name
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
  length  = 16
  upper   = true
  lower   = true
  special = false
}

resource "vault_kv_secret_v2" "main" {
  mount = var.vault_mount_path
  name  = format("%s/%s/%s", var.destination.namespace, var.chart, "grafana")

  data_json = jsonencode(
    {
      username = "admin"
      password = random_string.main.result
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
