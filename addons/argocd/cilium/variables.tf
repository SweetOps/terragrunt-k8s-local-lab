variable "chart" {
  type        = string
  description = "The name of the chart to install"
  default     = "cilium"
}

variable "repository" {
  type        = string
  description = "The URL of the chart repository"
  default     = "https://helm.cilium.io/"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = "1.18.6"
}

variable "override_values" {
  type        = string
  description = "A helm values to override the default values"
  default     = ""
}

variable "metadata" {
  type = object(
    {
      name      = optional(string, "cilium")
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
      namespace = optional(string, "kube-system")
    }
  )
  default     = {}
  description = "Destination cluster and namespace"
}

variable "cascade" {
  type        = bool
  default     = false
  description = "Whether to applying cascading deletion when application is removed"
}

variable "wait" {
  type        = bool
  default     = false
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
  default     = ["CreateNamespace=true", "ApplyOutOfSyncOnly=true", "ServerSideApply=true"]
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

variable "k8s_api_server_port" {
  description = "The port of the Kubernetes API server"
  type        = number
  default     = 6443
}

variable "k8s_pod_subnet" {
  description = "The pod subnet for the Kubernetes cluster"
  type        = string
  default     = "10.244.0.0/16"
}

variable "k8s_cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "dev"
}
