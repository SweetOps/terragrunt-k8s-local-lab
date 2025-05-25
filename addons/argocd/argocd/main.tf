locals {
  hostname = "argocd.${var.domain}"

  metrics_defaults = {
    enabled = true
    serviceMonitor = {
      enabled = true
    }
  }

  values = {
    global = {
      domain = local.hostname
    }

    fullnameOverride = "argocd"
    dex = {
      enabled = false
    }
    controller = {
      metrics = {
        enabled = true
        serviceMonitor = {
          enabled = true
        }
      }
    }
    configs = {
      cm = {
        "accounts.kind_cluster" = "apiKey,login"
      }
      params = {
        "server.insecure" = true
      }
      secret = {
        createSecret                   = true
        argocdServerAdminPassword      = "$2a$10$KVscBZGucWmkXd5HtFwSHeVGKrKJM9EfRotC9N.V6tbwrftV3ab.a"
        argocdServerAdminPasswordMtime = "2025-05-19T12:33:46Z"
      }
    }
    server = {
      ingress = {
        enabled = true
        annotations = {
          "nginx.ingress.kubernetes.io/proxy-buffering" = "off"
          "cert-manager.io/cluster-issuer"              = var.cluster_issuer_name
        }
        ingressClassName = "nginx"
        tls              = false
        hosts = [
          {
            host  = local.hostname
            paths = ["/"]
          }
        ]
        extraTls = [
          {
            secretName = local.hostname
            hosts      = [local.hostname]
          }
        ]
      }
      metrics = local.metrics_defaults
    }
    repoServer = {
      metrics = local.metrics_defaults
    }
    applicationSet = {
      metrics = local.metrics_defaults
    }
    redis = {
      metrics = local.metrics_defaults
    }
  }
}

module "argocd" {
  source = "../../../modules/argocd"

  chart         = var.chart
  repository    = var.repository
  chart_version = var.chart_version
  metadata      = var.metadata
  destination   = var.destination
  cascade       = var.cascade
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
