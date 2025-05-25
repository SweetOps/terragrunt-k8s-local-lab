variable "chart" {
  type        = string
  description = "The name of the chart to install"
  default     = "ingress-nginx"
}

variable "repository" {
  type        = string
  description = "The URL of the chart repository"
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = "4.12.2"
}

variable "override_values" {
  type        = string
  description = "A helm values to override the default values"
  default     = ""
}

variable "metadata" {
  type = object(
    {
      name      = optional(string, "")
      namespace = optional(string, "argocd")
    }
  )
  default     = {}
  description = "Kubernetes resource metadata"
}

variable "destination" {
  type = object(
    {
      server    = optional(string, "https://kubernetes.default.svc")
      namespace = optional(string, "ingress-nginx")
    }
  )
  default     = {}
  description = "Destination cluster and namespace"
}

variable "wait" {
  type        = bool
  default     = true
  description = "Wait for the application to be healthy and synced"
}

variable "sync_policy" {
  type = object(
    {
      prune       = optional(bool, true)
      self_heal   = optional(bool, true)
      allow_empty = optional(bool, false)
    }
  )
  default     = {}
  description = "Sync policy for the application"
}

variable "sync_options" {
  type        = list(string)
  default     = ["CreateNamespace=true", "ApplyOutOfSyncOnly=true"]
  description = "Sync options for the application"
}

variable "retry" {
  type = object(
    {
      limit            = optional(number, 5)
      backoff_duration = optional(string, "5s")
      max_duration     = optional(string, "1m")
      backoff_factor   = optional(number, 2)
    }
  )
  default     = {}
  description = "Retry policy for the application"
}
