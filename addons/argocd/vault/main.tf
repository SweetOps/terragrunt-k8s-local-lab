locals {
  token = random_password.main.result

  values = {
    fullNameOverride = "vault"
    injector = {
      enabled = false
    }
    server = {
      dataStorage = {
        enabled   = true
        size      = "1Gi"
        mountPath = "/vault/data"
      }
      dev = {
        enabled      = true
        devRootToken = local.token
      }
      ui = {
        enabled = true
      }
      serverTelemetry = {
        enabled = true
        serviceMonitor = {
          enabled = true
        }
      }
    }
  }
}

resource "random_password" "main" {
  length  = 32
  special = false
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
