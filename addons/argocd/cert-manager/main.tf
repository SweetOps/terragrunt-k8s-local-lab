locals {
  secret_name = "${var.cluster_issuer_name}-ca"

  extra_objects = {
    secret = {
      apiVersion = "v1"
      kind       = "Secret"
      metadata = {
        name = local.secret_name
        annotations = {
          "argocd.argoproj.io/sync-wave" = "5"
        }
      }
      type = "kubernetes.io/tls"
      data = {
        "tls.crt" = base64encode(file(var.tls_path.crt))
        "tls.key" = base64encode(file(var.tls_path.key))
      }
    }

    cluster_issuer = {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name = var.cluster_issuer_name
        annotations = {
          "argocd.argoproj.io/sync-wave" = "6"
        }
      }
      spec = {
        ca = {
          secretName = local.secret_name
        }
      }
    }
  }

  values = {
    fullnameOverride = "cert-manager"
    crds = {
      enabled = true
    }

    prometheus = {
      enabled = true
      servicemonitor = {
        enabled = true
      }
    }

    extraObjects = [
      yamlencode(local.extra_objects.secret),
      yamlencode(local.extra_objects.cluster_issuer)
    ]
  }
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
