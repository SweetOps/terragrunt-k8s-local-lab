locals {

  values = {
    server = {
      vmServiceScrape = {
        enabled = true
      }
    }
    vector = {
      enabled = true
    }
    dashboards = {
      enabled = true
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
    var.inherited_values,
    var.override_values,
  ]
}
