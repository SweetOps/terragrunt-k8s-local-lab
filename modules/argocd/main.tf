resource "argocd_application" "main" {
  metadata {
    name      = length(var.metadata.name) > 0 ? var.metadata.name : var.chart
    namespace = var.metadata.namespace
  }

  cascade = var.cascade
  wait    = var.wait

  spec {
    destination {
      server    = var.destination.server
      namespace = var.destination.namespace
    }

    source {
      repo_url        = var.repository
      chart           = var.chart
      target_revision = var.chart_version

      helm {
        values = var.values
      }
    }

    sync_policy {
      automated {
        prune       = var.sync_policy.prune
        self_heal   = var.sync_policy.self_heal
        allow_empty = var.sync_policy.allow_empty
      }

      sync_options = var.sync_options

      retry {
        limit = var.retry.limit
        backoff {
          duration     = var.retry.backoff_duration
          max_duration = var.retry.max_duration
          factor       = var.retry.backoff_factor
        }
      }
    }
  }
}
