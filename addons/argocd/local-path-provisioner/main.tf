locals {
  values = {
    fullnameOverride = "local-path-provisioner"
    storageClass = {
      create            = true
      defaultClass      = true
      defaultVolumeType = "hostPath"
      name              = "standard"
    }
    nodePathMap = [
      {
        node = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
        paths = [
          "/mnt/local-storage",
        ]
      },
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

