locals {
  hostname = "trow.${var.domain}"

  values = {
    trow = {
      fullNameOverride = "trow"
      domain           = local.hostname
    }
    ingress = {
      enabled = true
      annotations = {
        "cert-manager.io/cluster-issuer"              = "own"
        "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
      }
      ingressClassName = "nginx"
      hosts = [
        {
          host  = local.hostname
          paths = ["/"]
        }
      ]
      tls = [
        {
          secretName = local.hostname
          hosts      = [local.hostname]
        }
      ]
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
