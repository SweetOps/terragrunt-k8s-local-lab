variable "name" {
  type        = string
  description = "Release name."
  default     = "argocd"
}

variable "namespace" {
  type        = string
  description = "The namespace to install the release into."
  default     = "argocd"
}

variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = "https://argoproj.github.io/argo-helm"
}

variable "chart" {
  type        = string
  description = "Chart name to be installed."
  default     = "argo-cd"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = "7.9.1"
}

variable "override_values" {
  description = "Override values for the Helm chart"
  type        = string
  default     = ""
}

variable "max_history" {
  type        = number
  description = "Maximum number of release versions stored per release."
  default     = 10
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist."
  default     = true
}

variable "dependency_update" {
  type        = bool
  description = "Runs helm dependency update before installing the chart."
  default     = true
}

variable "reuse_values" {
  type        = bool
  description = "When upgrading, reuse the last release's values and merge in any overrides."
  default     = false
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful."
  default     = true
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation."
  default     = 600
}
