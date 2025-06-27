locals {
  values = {
    fullnameOverride = "argocd"
    dex = {
      enabled = false
    }
    configs = {
      cm = {
        "resource.customizations.ignoreDifferences.apps_Deployment" = <<-EOT
          jqPathExpressions:
            - ".spec.template.spec.containers[].env[]?.valueFrom.resourceFieldRef.divisor"
        EOT
      }
      params = {
        "server.insecure" = true
      }
    }
  }
}

module "helm" {
  source = "../../../modules/helm"

  name              = var.name
  repository        = var.repository
  chart             = var.chart
  chart_version     = var.chart_version
  namespace         = var.namespace
  create_namespace  = var.create_namespace
  max_history       = var.max_history
  dependency_update = var.dependency_update
  reuse_values      = var.reuse_values
  wait              = var.wait
  timeout           = var.timeout
  values            = data.utils_deep_merge_yaml.main.output
}

data "utils_deep_merge_yaml" "main" {
  input = [
    yamlencode(local.values),
    var.override_values,
  ]
}
