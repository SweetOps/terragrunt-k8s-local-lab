locals {
  values = {
    fullnameOverride = "argocd"
    dex = {
      enabled = false
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
        argocdServerAdminPasswordMtime = "2025-05-19T12:33:47Z"
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
