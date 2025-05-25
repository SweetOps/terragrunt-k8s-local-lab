resource "helm_release" "main" {
  name              = var.name
  repository        = var.repository
  chart             = var.chart
  version           = var.chart_version
  namespace         = var.namespace
  max_history       = var.max_history
  create_namespace  = var.create_namespace
  dependency_update = var.dependency_update
  reuse_values      = var.reuse_values
  wait              = var.wait
  timeout           = var.timeout
  values            = [var.values]
}
