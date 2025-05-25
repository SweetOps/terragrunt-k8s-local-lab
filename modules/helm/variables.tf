variable "name" {
  type        = string
  description = "Release name."
}

variable "namespace" {
  type        = string
  description = "The namespace to install the release into."
}

variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
}

variable "chart" {
  type        = string
  description = "Chart name to be installed."
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
}

variable "values" {
  type        = string
  description = "A helm values."
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
  default     = 300
}
